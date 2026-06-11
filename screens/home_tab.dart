// lib/screens/home_tab.dart
// View (MVVM) - HomeTab membaca data dari AuthViewModel via Provider
// Fokus: Edukasi Dermatologi, bukan klinik / booking dokter

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../theme.dart';
import 'scan_screen.dart';
import 'chatbot_screen.dart';
import 'disease_detail_screen.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    // Baca nama user dari AuthViewModel (MVVM pattern)
    final authVM = context.watch<AuthViewModel>();

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () => authVM.loadUserProfile(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // ── Greeting pakai data dari ViewModel ──
            Row(children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppTheme.primaryColor, AppTheme.accentColor]),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    authVM.userName.isNotEmpty ? authVM.userName[0].toUpperCase() : 'U',
                    style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                  'Halo, ${authVM.userName.split(' ').first}! 👋',
                  style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                ),
                Text('Selamat belajar tentang kesehatan kulit', style: GoogleFonts.poppins(fontSize: 12, color: AppTheme.textSecondary)),
              ])),
            ]),
            const SizedBox(height: 20),

            // ── Banner Utama ──
            Container(
              width: double.infinity, padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryColor, Color(0xFF1A6B4A)],
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [BoxShadow(color: AppTheme.primaryColor.withValues(alpha: 0.35), blurRadius: 20, offset: const Offset(0, 8))],
              ),
              child: Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
                    child: Text('Edukasi AI Dermatologi', style: GoogleFonts.poppins(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w500)),
                  ),
                  const SizedBox(height: 10),
                  Text('Kenali Penyakit\nKulit Lebih Awal', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white, height: 1.3)),
                  const SizedBox(height: 8),
                  Text('Scan foto kulit Anda untuk\nmengetahui kondisi kesehatan kulit', style: GoogleFonts.poppins(fontSize: 11, color: Colors.white70, height: 1.4)),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ScanScreen())),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.camera_alt_rounded, color: AppTheme.primaryColor, size: 16),
                        const SizedBox(width: 6),
                        Text('Scan Sekarang', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.primaryColor)),
                      ]),
                    ),
                  ),
                ])),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)),
                  child: const Icon(Icons.biotech_rounded, color: Colors.white, size: 52),
                ),
              ]),
            ),
            const SizedBox(height: 28),

            // ── Menu Fitur Utama (tanpa Dokter) ──
            Text('Fitur', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Row(children: [
              _FeatureCard(icon: Icons.camera_alt_rounded, label: 'Scan AI', color: AppTheme.primaryColor,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ScanScreen()))),
              const SizedBox(width: 12),
              _FeatureCard(icon: Icons.chat_bubble_rounded, label: 'Chatbot', color: Colors.purple,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatbotScreen()))),
            ]),
            const SizedBox(height: 28),

            // ── Daftar 10 Penyakit Kulit (Edukasi) ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('10 Penyakit Terdeteksi AI', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
                Text('Klik untuk belajar', style: GoogleFonts.poppins(fontSize: 11, color: AppTheme.primaryColor)),
              ],
            ),
            const SizedBox(height: 12),
            ..._diseaseData.map((d) => _DiseaseCard(disease: d)),
            const SizedBox(height: 20),

            // ── Tips Edukasi ──
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppTheme.infoColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.infoColor.withValues(alpha: 0.2)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.lightbulb_rounded, color: AppTheme.infoColor, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Tips Kesehatan Kulit', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.infoColor)),
                      const SizedBox(height: 4),
                      Text('Gunakan tabir surya SPF 30+ setiap hari, minum air putih cukup, dan periksa kulit secara rutin untuk deteksi dini masalah kulit.',
                        style: GoogleFonts.poppins(fontSize: 12, color: AppTheme.textSecondary, height: 1.5)),
                    ]),
                  ),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

// ── Daftar 10 Penyakit beserta data edukasi lengkap ──
final List<Map<String, dynamic>> _diseaseData = [
  {
    'name': 'Kanker Kulit & Lesi Solar',
    'icon': Icons.wb_sunny_rounded,
    'color': const Color(0xFFE53935),
    'severity': 'Tinggi',
    'description': 'Kanker kulit yang disebabkan oleh paparan sinar UV matahari berlebihan. Termasuk keratosis aktinik dan karsinoma sel skuamosa. Sering muncul di wajah, leher, dan tangan.',
    'symptoms': ['Bercak bersisik kemerahan di kulit yang terpapar matahari', 'Luka yang tidak sembuh dalam beberapa minggu', 'Perubahan warna atau tekstur kulit secara tiba-tiba'],
    'prevention': ['Gunakan tabir surya SPF 50+ setiap hari', 'Hindari paparan matahari pukul 10.00–16.00', 'Pakai topi dan pakaian pelindung saat di luar', 'Periksa kulit secara rutin setiap 3–6 bulan'],
    'recommendations': ['Segera konsultasi dokter spesialis kulit', 'Jangan mencoba mengobati sendiri', 'Lakukan pemeriksaan dermoskopi'],
  },
  {
    'name': 'Melanoma',
    'icon': Icons.warning_rounded,
    'color': const Color(0xFFD32F2F),
    'severity': 'Sangat Tinggi',
    'description': 'Jenis kanker kulit paling agresif yang berkembang dari sel melanosit. Dapat menyebar ke organ lain. Tingkat kesembuhan >95% jika terdeteksi dini.',
    'symptoms': ['Tahi lalat baru yang tidak biasa', 'Tahi lalat berubah ukuran, warna, atau bentuk', 'Lesi kulit yang gatal atau berdarah'],
    'prevention': ['Gunakan metode ABCDE untuk memantau tahi lalat', 'Hindari paparan sinar UV berlebihan', 'Lakukan pemeriksaan kulit profesional tahunan'],
    'recommendations': ['SEGERA kunjungi dokter atau rumah sakit', 'Tanyakan tentang pemeriksaan biopsi', 'Dokumentasi perubahan dengan foto berkala'],
  },
  {
    'name': 'Eksim Atopik',
    'icon': Icons.healing_rounded,
    'color': const Color(0xFFF57C00),
    'severity': 'Sedang',
    'description': 'Kondisi kulit kronis yang menyebabkan kulit merah, gatal, kering, dan meradang. Sering di lipatan siku, lutut, dan leher. Berkaitan dengan alergi.',
    'symptoms': ['Kulit kemerahan dan gatal hebat', 'Kulit kering dan bersisik', 'Ruam yang bisa mengeluarkan cairan saat digaruk'],
    'prevention': ['Gunakan pelembap 2x sehari', 'Hindari sabun keras dan deterjen', 'Kenakan pakaian katun lembut', 'Kelola stres dengan baik'],
    'recommendations': ['Konsultasi dokter untuk krim kortikosteroid', 'Identifikasi dan hindari pemicu alergi', 'Jaga kelembapan kulit setiap hari'],
  },
  {
    'name': 'Karsinoma Sel Basal',
    'icon': Icons.error_rounded,
    'color': const Color(0xFFE53935),
    'severity': 'Tinggi',
    'description': 'Jenis kanker kulit paling umum namun tumbuh lambat dan jarang menyebar. Biasanya muncul sebagai benjolan berkilau atau luka yang tidak sembuh.',
    'symptoms': ['Benjolan berkilau seperti mutiara', 'Luka datar yang menyerupai bekas luka', 'Area kulit kemerahan yang tidak sembuh'],
    'prevention': ['Lindungi kulit dari sinar UV setiap hari', 'Hindari tanning bed', 'Pemeriksaan kulit rutin'],
    'recommendations': ['Konsultasi dokter untuk evaluasi', 'Pengobatan melalui pembedahan minor', 'Pemeriksaan rutin setelah pengobatan'],
  },
  {
    'name': 'Tahi Lalat (Nevus)',
    'icon': Icons.circle,
    'color': const Color(0xFF4CAF50),
    'severity': 'Rendah',
    'description': 'Pertumbuhan kulit jinak dari kumpulan melanosit. Umumnya tidak berbahaya, namun perlu dipantau dengan metode ABCDE.',
    'symptoms': ['Bercak cokelat atau hitam pada kulit', 'Permukaan rata atau sedikit menonjol', 'Umumnya berukuran < 6mm'],
    'prevention': ['Pantau dengan metode ABCDE secara berkala', 'Foto tahi lalat untuk perbandingan', 'Lindungi dari sinar matahari'],
    'recommendations': ['Pemeriksaan profesional setahun sekali', 'Segera periksa jika ada perubahan', 'Jangan menghilangkan tahi lalat sendiri'],
  },
  {
    'name': 'Keratosis Jinak',
    'icon': Icons.spa_rounded,
    'color': const Color(0xFF2196F3),
    'severity': 'Rendah',
    'description': 'Pertumbuhan kulit jinak berupa bercak tebal dan kasar. Umumnya tidak berbahaya dan tidak memerlukan pengobatan medis khusus.',
    'symptoms': ['Bercak kasar dan tebal pada kulit', 'Warna kecokelatan atau kehitaman', 'Terasa seperti benda menempel di kulit'],
    'prevention': ['Jaga kelembapan kulit', 'Hindari iritasi pada area terkena', 'Pemeriksaan berkala untuk memastikan jinak'],
    'recommendations': ['Tidak perlu pengobatan jika tidak mengganggu', 'Konsultasi dokter jika lesi berubah cepat', 'Jangan menggaruk atau menghilangkan sendiri'],
  },
  {
    'name': 'Psoriasis',
    'icon': Icons.grain_rounded,
    'color': const Color(0xFF9C27B0),
    'severity': 'Sedang',
    'description': 'Penyakit autoimun kronis: sel kulit berkembang 10x lebih cepat, menghasilkan bercak tebal merah bersisik perak. Tidak menular.',
    'symptoms': ['Bercak merah bersisik tebal berwarna perak', 'Kulit kering dan mudah retak berdarah', 'Gatal dan rasa terbakar pada area terkena'],
    'prevention': ['Kelola stres karena dapat memperburuk kondisi', 'Jaga kelembapan kulit dengan pelembap rutin', 'Hindari luka dan gesekan pada kulit'],
    'recommendations': ['Konsultasi dokter untuk rencana pengobatan', 'Pertimbangkan fototerapi jika direkomendasikan', 'Tanyakan tentang terapi biologis untuk kasus berat'],
  },
  {
    'name': 'Keratosis Seboroik',
    'icon': Icons.texture_rounded,
    'color': const Color(0xFF795548),
    'severity': 'Rendah',
    'description': 'Pertumbuhan kulit jinak umum pada usia >50 tahun. Tampak seperti bercak cokelat/hitam "menempel" pada kulit. Tidak berbahaya.',
    'symptoms': ['Bercak cokelat atau hitam dengan permukaan kasar', 'Tampak seperti "ditempel" pada kulit', 'Umumnya tidak menyebabkan rasa sakit'],
    'prevention': ['Tidak ada pencegahan khusus karena faktor usia', 'Lindungi kulit dari paparan UV berlebihan', 'Pemeriksaan rutin untuk memastikan diagnosis'],
    'recommendations': ['Tidak perlu pengobatan jika tidak mengganggu', 'Bisa dihilangkan untuk alasan kosmetik (krioterapi)', 'Periksakan jika tumbuh cepat atau berdarah'],
  },
  {
    'name': 'Infeksi Jamur',
    'icon': Icons.bug_report_rounded,
    'color': const Color(0xFFFF9800),
    'severity': 'Rendah',
    'description': 'Infeksi kulit oleh jamur, sangat umum di Indonesia karena iklim tropis. Termasuk kurap, kandidiasis, dan panu.',
    'symptoms': ['Ruam merah berbentuk lingkaran yang gatal', 'Kulit mengelupas di tepi ruam', 'Bercak putih atau cokelat pada kulit (panu)'],
    'prevention': ['Jaga kulit tetap bersih dan kering', 'Kenakan pakaian longgar berbahan katun', 'Jangan berbagi handuk atau pakaian', 'Ganti pakaian basah segera'],
    'recommendations': ['Gunakan krim antijamur sesuai petunjuk', 'Konsultasi dokter jika tidak membaik 2 minggu', 'Jaga area terkena tetap kering'],
  },
  {
    'name': 'Infeksi Virus (Kutil)',
    'icon': Icons.coronavirus_rounded,
    'color': const Color(0xFF607D8B),
    'severity': 'Rendah',
    'description': 'Infeksi kulit oleh virus HPV (kutil) dan poxvirus (molluscum). Menular melalui kontak langsung.',
    'symptoms': ['Benjolan kasar keras berwarna daging', 'Titik-titik hitam kecil pada benjolan', 'Benjolan kecil dengan cekungan di tengah (molluscum)'],
    'prevention': ['Jaga kebersihan tangan secara rutin', 'Hindari menyentuh kutil orang lain', 'Gunakan alas kaki di tempat umum basah', 'Jangan berbagi alat cukur'],
    'recommendations': ['Biasanya hilang sendiri dalam beberapa bulan', 'Konsultasi dokter untuk krioterapi jika diperlukan', 'Hindari menggaruk atau memencet kutil'],
  },
];

// ── Widget Helper ──
class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _FeatureCard({required this.icon, required this.label, required this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.2)),
            boxShadow: [BoxShadow(color: color.withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, 4))],
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(14)),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(height: 10),
            Text(label, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
          ]),
        ),
      ),
    );
  }
}

class _DiseaseCard extends StatelessWidget {
  final Map<String, dynamic> disease;
  const _DiseaseCard({required this.disease});

  @override
  Widget build(BuildContext context) {
    final color = disease['color'] as Color;
    final severity = disease['severity'] as String;
    final sevColor = AppTheme.severityColor(severity);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => DiseaseDetailScreen(disease: disease)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(11)),
            child: Icon(disease['icon'] as IconData, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(disease['name'] as String, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 3),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: sevColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
              child: Text('Risiko: $severity', style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600, color: sevColor)),
            ),
          ])),
          Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400, size: 20),
        ]),
      ),
    );
  }
}
