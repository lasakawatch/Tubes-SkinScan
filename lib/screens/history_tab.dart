// lib/screens/history_tab.dart
// View (MVVM) - membaca dari HistoryViewModel via Provider
// CRUD: Read (load) + Delete (hapus item)

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../viewmodels/history_viewmodel.dart';
import '../theme.dart';

class HistoryTab extends StatefulWidget {
  const HistoryTab({super.key});
  @override
  State<HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<HistoryTab> {
  @override
  void initState() {
    super.initState();
    // Muat data saat halaman dibuka
    Future.microtask(() => context.read<HistoryViewModel>().loadHistory());
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HistoryViewModel>();

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
            child: Row(
              children: [
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Riwayat Scan', style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold)),
                    Text('${vm.totalScans} hasil scan tersimpan', style: GoogleFonts.poppins(fontSize: 13, color: AppTheme.textSecondary)),
                  ]),
                ),
                // Tombol Refresh
                IconButton(
                  onPressed: vm.loadHistory,
                  icon: const Icon(Icons.refresh_rounded),
                  color: AppTheme.primaryColor,
                ),
              ],
            ),
          ),

          // ── Konten ──
          Expanded(
            child: vm.isLoading
                ? const Center(child: CircularProgressIndicator())
                : vm.history.isEmpty
                    ? _buildEmpty()
                    : RefreshIndicator(
                        onRefresh: vm.loadHistory,
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                          itemCount: vm.history.length,
                          itemBuilder: (ctx, i) => _buildCard(ctx, vm, vm.history[i], i),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(color: AppTheme.primaryLight, shape: BoxShape.circle),
          child: const Icon(Icons.history_rounded, size: 56, color: AppTheme.primaryColor),
        ),
        const SizedBox(height: 20),
        Text('Belum ada riwayat scan', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
        const SizedBox(height: 6),
        Text('Coba fitur Scan AI untuk mulai', style: GoogleFonts.poppins(fontSize: 13, color: AppTheme.textSecondary)),
      ]),
    );
  }

  Widget _buildCard(BuildContext context, HistoryViewModel vm, Map<String, dynamic> item, int index) {
    final result = item['result'];
    String label = 'Unknown';
    double confidence = 0;
    String severity = 'rendah';

    if (result is Map) {
      label = (result['label'] ?? 'Unknown').toString();
      confidence = (result['confidence'] ?? 0).toDouble();
      severity = (result['severity'] ?? 'rendah').toString();
    }

    final sevColor = AppTheme.severityColor(severity);
    final pct = (confidence * 100).toStringAsFixed(1);
    final docId = item['id'] as String? ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(children: [
        Container(
          width: 50, height: 50,
          decoration: BoxDecoration(color: sevColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14)),
          child: Icon(Icons.biotech_rounded, color: sevColor, size: 24),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600), maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 6),
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: sevColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
              child: Text(severity.toUpperCase(), style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600, color: sevColor)),
            ),
            const SizedBox(width: 8),
            Text('$pct%', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.primaryColor)),
          ]),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: confidence, minHeight: 5,
              backgroundColor: Colors.grey.shade100,
              valueColor: AlwaysStoppedAnimation(sevColor),
            ),
          ),
        ])),
        const SizedBox(width: 8),
        // ── DELETE button (CRUD - Delete) ──
        IconButton(
          icon: Icon(Icons.delete_outline_rounded, color: Colors.red.shade300, size: 22),
          onPressed: () => _confirmDelete(context, vm, docId, label),
        ),
      ]),
    );
  }

  /// Dialog konfirmasi sebelum menghapus
  void _confirmDelete(BuildContext context, HistoryViewModel vm, String docId, String label) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Hapus Riwayat?', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: Text('Yakin ingin menghapus hasil scan "$label"?', style: GoogleFonts.poppins(fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Batal', style: GoogleFonts.poppins(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await vm.deleteHistory(docId);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Riwayat dihapus', style: GoogleFonts.poppins()), backgroundColor: AppTheme.primaryColor, behavior: SnackBarBehavior.floating),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
            child: Text('Hapus', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
