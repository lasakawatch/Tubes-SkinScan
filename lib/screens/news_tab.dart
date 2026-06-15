// lib/screens/news_tab.dart
// Tab Edukasi - Artikel edukasi dermatologi dengan integrasi URL Eksternal

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme.dart';

class NewsTab extends StatelessWidget {
  const NewsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Edukasi Kulit', style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold)),
          Text('Belajar dari sumber medis terpercaya', style: GoogleFonts.poppins(fontSize: 13, color: AppTheme.textSecondary)),
          const SizedBox(height: 20),

          // Featured card
          _FeaturedCard(
            title: 'Metode ABCDE: Deteksi Dini Kanker Kulit',
            subtitle: 'Panduan lengkap dari pakar untuk memantau perubahan tahi lalat dan mendeteksi melanoma.',
            icon: Icons.monitor_heart_rounded,
            color: const Color(0xFFD32F2F),
            readTime: '3 min baca',
            url: 'https://www.halodoc.com/artikel/abcde-melanoma-kenali-tanda-awal-kanker-kulit?srsltid=AfmBOopCF72bwTsjQmbQHRXef6ams-9Y-JwvISJfsR_zZeqWZZdR6REx',
            content: 'Metode ABCDE adalah panduan sederhana untuk mengenali tanda-tanda awal melanoma:\n\n'
                '🔴 A - Asimetri: Bentuk tahi lalat tidak simetris\n'
                '🔴 B - Border: Tepi tidak rata atau tidak jelas\n'
                '🔴 C - Color: Warna tidak merata (cokelat, hitam, merah)\n'
                '🔴 D - Diameter: Ukuran lebih dari 6mm\n'
                '🔴 E - Evolving: Berubah ukuran, bentuk, atau warna\n\n'
                'Deteksi dini meningkatkan peluang kesembuhan hingga 95%.',
          ),
          const SizedBox(height: 14),

          // Info API / Sumber
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(color: AppTheme.primaryLight, borderRadius: BorderRadius.circular(12)),
            child: Row(children: [
              const Icon(Icons.language_rounded, color: AppTheme.primaryColor, size: 20),
              const SizedBox(width: 10),
              Expanded(child: Text('Diperkaya dengan tautan eksternal ke portal medis ternama (Alodokter, Halodoc, dll).', style: GoogleFonts.poppins(fontSize: 11, color: AppTheme.primaryColor, fontWeight: FontWeight.w500))),
            ]),
          ),
          const SizedBox(height: 14),

          // Artikel grid
          ..._articles.map((a) => _ArticleCard(article: a)),
        ]),
      ),
    );
  }
}

// ── Data Artikel Edukasi dengan Link Web (Browser API Simulation) ──
final List<Map<String, dynamic>> _articles = [
  {
    'title': 'Cara Melindungi Kulit dari Sinar UV Berbahaya',
    'summary': 'Sinar UV adalah penyebab utama penuaan kulit dan kanker. Pelajari cara perlindungannya.',
    'icon': Icons.wb_sunny_rounded,
    'color': Color(0xFFF57C00),
    'tag': 'Pencegahan',
    'readTime': '4 min',
    'url': 'https://www.halodoc.com/artikel/5-tips-melindungi-diri-dari-sinar-uv-saat-mudik?srsltid=AfmBOoqXhFcSc0EfMUUfOA-23YT5hkEaz4tp4DF3zWvsLJmYEtczHrb7',
    'content': 'Paparan sinar UV berlebihan menyebabkan kerusakan DNA pada sel kulit. Gunakan sunscreen SPF 30+ setiap hari, hindari matahari pukul 10-16, dan kenakan pakaian pelindung. Aplikasikan ulang sunscreen setiap 2 jam saat beraktivitas di luar ruangan.',
  },
  {
    'title': 'Perbedaan Jerawat dan Rosacea',
    'summary': 'Kondisi kulit ini tampak serupa tapi membutuhkan penanganan yang sangat berbeda.',
    'icon': Icons.face_rounded,
    'color': Color(0xFF9C27B0),
    'tag': 'Edukasi',
    'readTime': '5 min',
    'url': 'https://www.alodokter.com/rosacea',
    'content': 'Jerawat disebabkan oleh pori tersumbat dan bakteri, sedangkan rosacea adalah kondisi peradangan pembuluh darah di wajah. Jerawat lebih umum di usia remaja, sementara rosacea biasanya muncul pada usia 30-50 tahun dan sering dipicu oleh makanan pedas atau cuaca ekstrem.',
  },
  {
    'title': 'Mengatasi Eksim Atopik (Dermatitis)',
    'summary': 'Panduan medis untuk meredakan gatal dan peradangan kulit kronis.',
    'icon': Icons.healing_rounded,
    'color': Color(0xFF2196F3),
    'tag': 'Perawatan',
    'readTime': '3 min',
    'url': 'https://www.alodokter.com/eksim-atopik',
    'content': 'Kulit eksim disebabkan oleh penghalang kulit (skin barrier) yang lemah. Gunakan pelembap tebal langsung setelah mandi, pilih produk bebas parfum (fragrance-free), dan hindari mandi dengan air terlalu panas karena dapat menghilangkan minyak alami kulit.',
  },
  {
    'title': 'Infeksi Jamur Kulit di Iklim Tropis',
    'summary': 'Penyebab, gejala, dan cara pengobatan panu serta kurap di Indonesia.',
    'icon': Icons.bug_report_rounded,
    'color': Color(0xFFFF9800),
    'tag': 'Edukasi',
    'readTime': '4 min',
    'url': 'https://www.halodoc.com/kesehatan/jamur-kulit?srsltid=AfmBOopteZYfgjWznyERQUSCNo52gm_lbqXJe6obkz-O_D-Y2lkgzZSv',
    'content': 'Kurap (ringworm), panu, dan kandidiasis sangat mudah berkembang di lingkungan lembap. Jaga kulit tetap kering, pakai pakaian berbahan katun yang menyerap keringat, dan segera ganti baju setelah berolahraga untuk mencegah jamur berkembang biak.',
  },
];

// ── Fungsi Buka URL (Browser) ──
Future<void> _launchUrl(String urlString) async {
  final Uri url = Uri.parse(urlString);
  if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
    debugPrint('Gagal membuka link: $urlString');
  }
}

// ── Widget ──
class _FeaturedCard extends StatelessWidget {
  final String title, subtitle, readTime, content, url;
  final IconData icon;
  final Color color;

  const _FeaturedCard({required this.title, required this.subtitle, required this.icon, required this.color, required this.readTime, required this.content, required this.url});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showDetail(context),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [color, color.withValues(alpha: 0.7)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 6))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
              child: Text('FEATURED', style: GoogleFonts.poppins(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w600)),
            ),
          ]),
          const SizedBox(height: 14),
          Text(title, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white, height: 1.3)),
          const SizedBox(height: 8),
          Text(subtitle, style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70, height: 1.4), maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 14),
          Row(children: [
            const Icon(Icons.schedule_rounded, size: 14, color: Colors.white70),
            const SizedBox(width: 4),
            Text(readTime, style: GoogleFonts.poppins(fontSize: 11, color: Colors.white70)),
            const Spacer(),
            Text('Baca & Buka Link →', style: GoogleFonts.poppins(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600)),
          ]),
        ]),
      ),
    );
  }

  void _showDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => DraggableScrollableSheet(
        expand: false, initialChildSize: 0.75, maxChildSize: 0.95,
        builder: (_, ctrl) => SingleChildScrollView(
          controller: ctrl,
          padding: const EdgeInsets.all(24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),
            Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 24)),
            const SizedBox(height: 12),
            Text(title, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Text(content, style: GoogleFonts.poppins(fontSize: 14, color: AppTheme.textSecondary, height: 1.7)),
            const SizedBox(height: 24),
            
            // Tombol Browser Eksternal
            SizedBox(
              width: double.infinity, height: 50,
              child: ElevatedButton.icon(
                onPressed: () => _launchUrl(url),
                icon: const Icon(Icons.open_in_browser_rounded),
                label: Text('Baca Sumber Asli di Web', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(backgroundColor: color, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class _ArticleCard extends StatelessWidget {
  final Map<String, dynamic> article;
  const _ArticleCard({required this.article});

  @override
  Widget build(BuildContext context) {
    final color = article['color'] as Color;

    return GestureDetector(
      onTap: () => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        builder: (_) => DraggableScrollableSheet(
          expand: false, initialChildSize: 0.65, maxChildSize: 0.95,
          builder: (_, ctrl) => SingleChildScrollView(
            controller: ctrl,
            padding: const EdgeInsets.all(24),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 20),
              Text(article['title'] as String, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Text(article['content'] as String, style: GoogleFonts.poppins(fontSize: 14, color: AppTheme.textSecondary, height: 1.7)),
              const SizedBox(height: 24),
              
              // Tombol Web Eksternal
              SizedBox(
                width: double.infinity, height: 50,
                child: ElevatedButton.icon(
                  onPressed: () => _launchUrl(article['url'] as String),
                  icon: const Icon(Icons.open_in_browser_rounded),
                  label: Text('Baca Artikel Lengkap di Web', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(backgroundColor: color, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                ),
              ),
            ]),
          ),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade100)),
        child: Row(children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14)),
            child: Icon(article['icon'] as IconData, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                child: Text(article['tag'] as String, style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600, color: color)),
              ),
              const SizedBox(width: 6),
              Text(article['readTime'] as String, style: GoogleFonts.poppins(fontSize: 10, color: AppTheme.textSecondary)),
            ]),
            const SizedBox(height: 6),
            Text(article['title'] as String, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600), maxLines: 2, overflow: TextOverflow.ellipsis),
          ])),
          Icon(Icons.open_in_new_rounded, color: Colors.grey.shade400, size: 20),
        ]),
      ),
    );
  }
}
