// lib/screens/disease_detail_screen.dart
// Halaman EDUKASI detail penyakit kulit
// Menampilkan: deskripsi, gejala, pencegahan, tingkat keparahan

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';

class DiseaseDetailScreen extends StatelessWidget {
  final Map<String, dynamic> disease;

  const DiseaseDetailScreen({super.key, required this.disease});

  @override
  Widget build(BuildContext context) {
    final color = disease['color'] as Color? ?? AppTheme.primaryColor;
    final severity = disease['severity'] as String? ?? 'Sedang';
    final sevColor = AppTheme.severityColor(severity);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Header dengan gradient warna penyakit
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: color,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withValues(alpha: 0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 80, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(disease['icon'] as IconData, color: Colors.white, size: 32),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        disease['name'] as String,
                        style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Tingkat Risiko: $severity',
                          style: GoogleFonts.poppins(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Deskripsi
                  _sectionCard(
                    icon: Icons.info_outline_rounded,
                    title: 'Tentang Penyakit Ini',
                    color: AppTheme.infoColor,
                    child: Text(
                      disease['description'] as String? ?? '-',
                      style: GoogleFonts.poppins(fontSize: 14, color: AppTheme.textSecondary, height: 1.6),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Gejala
                  if (disease['symptoms'] != null)
                    _sectionCard(
                      icon: Icons.monitor_heart_rounded,
                      title: 'Gejala Umum',
                      color: AppTheme.warningColor,
                      child: _bulletList(disease['symptoms'] as List<String>, AppTheme.warningColor),
                    ),
                  const SizedBox(height: 16),

                  // Pencegahan
                  if (disease['prevention'] != null)
                    _sectionCard(
                      icon: Icons.shield_rounded,
                      title: 'Cara Pencegahan',
                      color: AppTheme.successColor,
                      child: _bulletList(disease['prevention'] as List<String>, AppTheme.successColor),
                    ),
                  const SizedBox(height: 16),

                  // Rekomendasi
                  if (disease['recommendations'] != null)
                    _sectionCard(
                      icon: Icons.medical_services_rounded,
                      title: 'Rekomendasi',
                      color: sevColor,
                      child: _bulletList(disease['recommendations'] as List<String>, sevColor),
                    ),
                  const SizedBox(height: 24),

                  // Disclaimer
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.warningColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.warningColor.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.school_rounded, color: AppTheme.warningColor, size: 22),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Informasi ini bersifat edukatif. Untuk diagnosis dan pengobatan, selalu konsultasikan dengan dokter spesialis kulit (dermatologis).',
                            style: GoogleFonts.poppins(fontSize: 12, color: AppTheme.warningColor, height: 1.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({
    required IconData icon,
    required String title,
    required Color color,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 10),
              Text(title, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _bulletList(List<String> items, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map((item) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 6),
              width: 7, height: 7,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(item, style: GoogleFonts.poppins(fontSize: 13, color: AppTheme.textSecondary, height: 1.5)),
            ),
          ],
        ),
      )).toList(),
    );
  }
}
