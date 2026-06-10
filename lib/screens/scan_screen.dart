// lib/screens/scan_screen.dart
// View (MVVM) - Scan menggunakan ScanViewModel

import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../viewmodels/scan_viewmodel.dart';
import '../theme.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});
  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  Uint8List? _bytes;
  XFile? _picked;

  @override
  void initState() {
    super.initState();
    // Inisialisasi model TFLite via ViewModel
    Future.microtask(() => context.read<ScanViewModel>().initMl());
  }

  Future<void> _pick(ImageSource src) async {
    final f = await ImagePicker().pickImage(source: src, maxWidth: 800, maxHeight: 800, imageQuality: 85);
    if (f != null) {
      final b = await f.readAsBytes();
      setState(() { _picked = f; _bytes = b; });
      context.read<ScanViewModel>().clearResult();
    }
  }

  Future<void> _scan() async {
    if (_bytes == null) return;
    await context.read<ScanViewModel>().scan(_bytes!);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ScanViewModel>();
    final severity = (vm.scanResult?['severity'] ?? 'rendah').toString();
    final sevColor = AppTheme.severityColor(severity);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Kulit AI'),
        actions: [
          if (vm.mlReady)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Tooltip(
                message: 'Model DermaAid (86% akurasi) aktif',
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF34D399), shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    Text('AI Ready', style: GoogleFonts.poppins(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w500)),
                  ]),
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [

          // ── Gambar ──
          Container(
            height: 280,
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade200, width: 1.5),
            ),
            child: _bytes != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(19),
                    child: Image.memory(_bytes!, fit: BoxFit.cover, width: double.infinity),
                  )
                : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(color: AppTheme.primaryLight, shape: BoxShape.circle),
                      child: Icon(Icons.add_photo_alternate_rounded, size: 52, color: AppTheme.primaryColor.withValues(alpha: 0.6)),
                    ),
                    const SizedBox(height: 16),
                    Text('Ambil foto atau pilih dari galeri', style: GoogleFonts.poppins(fontSize: 14, color: AppTheme.textSecondary)),
                    Text('untuk memulai analisis AI', style: GoogleFonts.poppins(fontSize: 12, color: AppTheme.textSecondary)),
                  ]),
          ),
          const SizedBox(height: 16),

          // ── Tombol Pilih Gambar ──
          Row(children: [
            if (!kIsWeb) ...[
              Expanded(child: _actionBtn(Icons.camera_alt_rounded, 'Kamera', () => _pick(ImageSource.camera))),
              const SizedBox(width: 12),
            ],
            Expanded(child: _actionBtn(Icons.photo_library_rounded, kIsWeb ? 'Pilih Gambar' : 'Galeri', () => _pick(ImageSource.gallery))),
          ]),
          const SizedBox(height: 16),

          // ── Tombol Scan ──
          SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: _picked != null && !vm.isScanning ? _scan : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                disabledBackgroundColor: Colors.grey.shade300,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: vm.isScanning
                  ? Row(mainAxisSize: MainAxisSize.min, children: [
                      const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5)),
                      const SizedBox(width: 12),
                      Text('Menganalisa dengan AI...', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600)),
                    ])
                  : Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.biotech_rounded, size: 22),
                      const SizedBox(width: 8),
                      Text('Analisa Sekarang', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
                    ]),
            ),
          ),
          const SizedBox(height: 24),

          // ── Error ──
          if (vm.errorMessage != null)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: AppTheme.errorColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14)),
              child: Text(vm.errorMessage!, style: GoogleFonts.poppins(color: AppTheme.errorColor, fontSize: 13)),
            ),

          // ── Hasil Scan ──
          if (vm.scanResult != null) ...[
            Row(children: [
              Expanded(child: Text('Hasil Analisis AI', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold))),
              if (vm.scanSource.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: AppTheme.primaryLight, borderRadius: BorderRadius.circular(8)),
                  child: Text(vm.scanSource, style: GoogleFonts.poppins(fontSize: 9, color: AppTheme.primaryColor, fontWeight: FontWeight.w600)),
                ),
            ]),
            const SizedBox(height: 14),

            // Card hasil
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade100),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 16, offset: const Offset(0, 4))],
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: sevColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14)),
                    child: Icon(Icons.biotech_rounded, color: sevColor, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(vm.scanResult!['label'] ?? 'Unknown', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(color: sevColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                      child: Text('Tingkat Risiko: ${severity.toUpperCase()}', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: sevColor)),
                    ),
                  ])),
                ]),
                const SizedBox(height: 16),

                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('Confidence AI', style: GoogleFonts.poppins(fontSize: 13, color: AppTheme.textSecondary)),
                  Text('${((vm.scanResult!['confidence'] ?? 0) * 100).toStringAsFixed(1)}%',
                      style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.primaryColor)),
                ]),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: (vm.scanResult!['confidence'] ?? 0).toDouble(),
                    minHeight: 8,
                    backgroundColor: Colors.grey.shade100,
                    valueColor: AlwaysStoppedAnimation(sevColor),
                  ),
                ),

                if (vm.scanResult!['description'] != null) ...[
                  const SizedBox(height: 18),
                  Text('Deskripsi', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  Text(vm.scanResult!['description'].toString(), style: GoogleFonts.poppins(fontSize: 13, color: AppTheme.textSecondary, height: 1.5)),
                ],

                if (vm.scanResult!['recommendations'] != null) ...[
                  const SizedBox(height: 18),
                  Text('Rekomendasi', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  ...(vm.scanResult!['recommendations'] as List).map((r) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Container(margin: const EdgeInsets.only(top: 6), width: 6, height: 6, decoration: BoxDecoration(color: AppTheme.primaryColor, shape: BoxShape.circle)),
                      const SizedBox(width: 10),
                      Expanded(child: Text(r.toString(), style: GoogleFonts.poppins(fontSize: 12, color: AppTheme.textSecondary, height: 1.4))),
                    ]),
                  )),
                ],
              ]),
            ),
            const SizedBox(height: 14),

            // Disclaimer edukasi
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.infoColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.infoColor.withValues(alpha: 0.2)),
              ),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Icon(Icons.school_rounded, color: AppTheme.infoColor, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Hasil ini bersifat edukatif dan bukan pengganti diagnosis medis profesional. Selalu konsultasikan kondisi kulit Anda kepada dokter spesialis kulit.',
                    style: GoogleFonts.poppins(fontSize: 11, color: AppTheme.infoColor, height: 1.4),
                  ),
                ),
              ]),
            ),
          ],
        ]),
      ),
    );
  }

  Widget _actionBtn(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.3)),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, color: AppTheme.primaryColor, size: 20),
          const SizedBox(width: 8),
          Text(label, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.primaryColor)),
        ]),
      ),
    );
  }
}
