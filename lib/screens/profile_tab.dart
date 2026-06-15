import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../theme.dart';
import 'login_screen.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AuthViewModel>();
    final initials = vm.userName.isNotEmpty
        ? vm.userName.split(' ').map((w) => w.isNotEmpty ? w[0] : '').take(2).join().toUpperCase()
        : 'U';

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
        child: Column(children: [
          // ── Profile Header ──
          Container(
            width: double.infinity, padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppTheme.primaryColor, AppTheme.primaryDark], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(children: [
              // Avatar dengan tombol ganti foto
              GestureDetector(
                onTap: () => _pickProfilePhoto(context, vm),
                child: Stack(
                  children: [
                    Container(
                      width: 90, height: 90,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 2),
                      ),
                      child: ClipOval(
                        child: vm.photoBase64 != null && vm.photoBase64!.isNotEmpty
                            ? Image.memory(
                                base64Decode(vm.photoBase64!),
                                fit: BoxFit.cover,
                                width: 90, height: 90,
                              )
                            : Center(child: Text(initials, style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white))),
                      ),
                    ),
                    Positioned(
                      bottom: 0, right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        child: const Icon(Icons.camera_alt_rounded, size: 16, color: AppTheme.primaryColor),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text('Tap foto untuk mengubah', style: GoogleFonts.poppins(fontSize: 10, color: Colors.white60)),
              const SizedBox(height: 8),
              Text(vm.userName.isEmpty ? 'User' : vm.userName, style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white)),
              Text(vm.userEmail, style: GoogleFonts.poppins(fontSize: 13, color: Colors.white70)),
              const SizedBox(height: 8),
              // Badge user aktif
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.circle, size: 8, color: Color(0xFF4ADE80)),
                  const SizedBox(width: 6),
                  Text('User Aktif', style: GoogleFonts.poppins(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w500)),
                ]),
              ),
            ]),
          ),
          const SizedBox(height: 24),

          // ── Menu Items ──
          _MenuItem(
            icon: Icons.edit_rounded,
            label: 'Edit Profil',
            onTap: () => _showEditProfile(context, vm),
          ),
          _MenuItem(icon: Icons.info_outline_rounded, label: 'Tentang Aplikasi', onTap: () {
            showAboutDialog(
              context: context,
              applicationName: 'SkinScan',
              applicationVersion: '1.0.0',
              children: [const Text('Aplikasi Edukasi Dermatologi berbasis AI.\nMendeteksi 10 jenis kondisi kulit dengan akurasi 86%.\n\nDikembangkan oleh Tim Megalodon\'s.')],
            );
          }),
          _MenuItem(
            icon: Icons.help_outline_rounded,
            label: 'Bantuan & FAQ',
            onTap: () => _showFAQ(context),
          ),
          const SizedBox(height: 24),

          // ── Logout ──
          SizedBox(
            width: double.infinity, height: 52,
            child: OutlinedButton.icon(
              onPressed: () async {
                await vm.logout();
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                }
              },
              icon: const Icon(Icons.logout_rounded, color: AppTheme.errorColor),
              label: Text('Keluar dari Akun', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppTheme.errorColor)),
              style: OutlinedButton.styleFrom(side: const BorderSide(color: AppTheme.errorColor), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
            ),
          ),
          const SizedBox(height: 16),
          Text('SkinScan v1.0.0 • Edukasi Dermatologi', style: GoogleFonts.poppins(fontSize: 11, color: AppTheme.textSecondary)),
          const SizedBox(height: 4),
          Text('Developed by Megalodon\'s Team', style: GoogleFonts.poppins(fontSize: 11, color: AppTheme.primaryColor, fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }

  // ── Ganti Foto Profil ──
  Future<void> _pickProfilePhoto(BuildContext context, AuthViewModel vm) async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            Text('Ganti Foto Profil', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded, color: AppTheme.primaryColor),
              title: Text('Ambil dari Kamera', style: GoogleFonts.poppins()),
              onTap: () async {
                Navigator.pop(ctx);
                await _uploadPhoto(context, vm, ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded, color: AppTheme.primaryColor),
              title: Text('Pilih dari Galeri', style: GoogleFonts.poppins()),
              onTap: () async {
                Navigator.pop(ctx);
                await _uploadPhoto(context, vm, ImageSource.gallery);
              },
            ),
            if (vm.photoUrl != null && vm.photoUrl!.isNotEmpty)
              ListTile(
                leading: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                title: Text('Hapus Foto', style: GoogleFonts.poppins(color: Colors.red)),
                onTap: () async {
                  Navigator.pop(ctx);
                  await vm.removePhoto();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Foto profil dihapus', style: GoogleFonts.poppins()), backgroundColor: AppTheme.primaryColor, behavior: SnackBarBehavior.floating),
                    );
                  }
                },
              ),
          ]),
        ),
      ),
    );
  }

  Future<void> _uploadPhoto(BuildContext context, AuthViewModel vm, ImageSource source) async {
    final picker = ImagePicker();
    final XFile? picked = await picker.pickImage(source: source, maxWidth: 512, maxHeight: 512, imageQuality: 80);
    if (picked == null) return;

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Mengunggah foto...', style: GoogleFonts.poppins()), backgroundColor: AppTheme.primaryColor, behavior: SnackBarBehavior.floating, duration: const Duration(seconds: 10)),
      );
    }

    final ok = await vm.uploadProfilePhoto(File(picked.path));

    if (context.mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ok ? 'Foto profil berhasil diperbarui! ✅' : 'Gagal mengunggah foto ❌', style: GoogleFonts.poppins()),
          backgroundColor: ok ? AppTheme.primaryColor : AppTheme.errorColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ── FAQ Page ──
  void _showFAQ(BuildContext context) {
    final faqs = [
      {'q': 'Apa itu SkinScan?', 'a': 'SkinScan adalah aplikasi edukasi dermatologi berbasis AI yang dapat membantu mendeteksi 10 jenis kondisi kulit menggunakan kamera HP Anda secara offline.'},
      {'q': 'Apakah hasil scan akurat?', 'a': 'Model AI kami memiliki akurasi 86% pada dataset uji. Namun hasil scan bersifat EDUKATIF dan bukan pengganti diagnosis dokter spesialis kulit.'},
      {'q': 'Apakah perlu koneksi internet?', 'a': 'Fitur Scan AI bekerja sepenuhnya offline. Namun fitur Chatbot SkinBot dan penyimpanan riwayat membutuhkan koneksi internet.'},
      {'q': 'Bagaimana cara scan yang benar?', 'a': 'Pastikan area kulit terlihat jelas, pencahayaan cukup, kamera fokus, dan jarak kamera ±15cm dari kulit. Hindari memfoto benda lain selain kulit.'},
      {'q': 'Apakah data saya aman?', 'a': 'Data Anda disimpan secara aman di Google Firebase dengan enkripsi penuh. Kami tidak membagikan data ke pihak ketiga manapun.'},
      {'q': 'Mengapa AI menolak gambar saya?', 'a': 'Jika confidence score di bawah 40%, AI menganggap gambar bukan kulit atau terlalu buram. Coba ulangi dengan foto yang lebih jelas dan fokus.'},
      {'q': 'Siapa pembuat aplikasi ini?', 'a': 'SkinScan dikembangkan oleh Tim Megalodon\'s dari Universitas Telkom sebagai proyek UAS Pemrograman Mobile.'},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => DraggableScrollableSheet(
        expand: false, initialChildSize: 0.80, maxChildSize: 0.95,
        builder: (_, ctrl) => Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Column(children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 16),
              Row(children: [
                Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppTheme.primaryLight, borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.help_outline_rounded, color: AppTheme.primaryColor, size: 20)),
                const SizedBox(width: 12),
                Text('Bantuan & FAQ', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
              ]),
              const SizedBox(height: 4),
              Text('Pertanyaan yang sering ditanyakan', style: GoogleFonts.poppins(fontSize: 12, color: AppTheme.textSecondary)),
            ]),
          ),
          const Divider(),
          Expanded(
            child: ListView.separated(
              controller: ctrl,
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
              itemCount: faqs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) => _FAQItem(q: faqs[i]['q']!, a: faqs[i]['a']!),
            ),
          ),
        ]),
      ),
    );
  }

  /// Dialog EDIT PROFIL (CRUD - Update)
  void _showEditProfile(BuildContext context, AuthViewModel vm) {
    final nameCtrl = TextEditingController(text: vm.userName);
    final phoneCtrl = TextEditingController(text: vm.userPhone);
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, top: 24, left: 20, right: 20),
        child: Form(
          key: formKey,
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(
              child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 20),
            Text('Edit Profil', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            TextFormField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Nama Lengkap', prefixIcon: Icon(Icons.person_outline_rounded)),
              validator: (v) => v == null || v.isEmpty ? 'Nama tidak boleh kosong' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Nomor HP', prefixIcon: Icon(Icons.phone_outlined)),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity, height: 52,
              child: ElevatedButton(
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    final ok = await vm.updateProfile(nameCtrl.text.trim(), phoneCtrl.text.trim());
                    if (ctx.mounted) {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(ok ? 'Profil berhasil diperbarui' : 'Gagal memperbarui profil', style: GoogleFonts.poppins()),
                        backgroundColor: ok ? AppTheme.primaryColor : AppTheme.errorColor,
                        behavior: SnackBarBehavior.floating,
                      ));
                    }
                  }
                },
                child: Text('Simpan Perubahan', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 20),
          ]),
        ),
      ),
    );
  }
}

// ── FAQ Item Widget ──
class _FAQItem extends StatefulWidget {
  final String q, a;
  const _FAQItem({required this.q, required this.a});
  @override
  State<_FAQItem> createState() => _FAQItemState();
}

class _FAQItemState extends State<_FAQItem> {
  bool _expanded = false;
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _expanded ? AppTheme.primaryColor : Colors.grey.shade200),
      ),
      child: ExpansionTile(
        onExpansionChanged: (v) => setState(() => _expanded = v),
        leading: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(color: AppTheme.primaryLight, borderRadius: BorderRadius.circular(8)),
          child: const Icon(Icons.question_mark_rounded, color: AppTheme.primaryColor, size: 16),
        ),
        title: Text(widget.q, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600)),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(widget.a, style: GoogleFonts.poppins(fontSize: 13, color: AppTheme.textSecondary, height: 1.6)),
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  const _MenuItem({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.grey.shade100)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: AppTheme.primaryLight, borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: AppTheme.primaryColor, size: 20),
        ),
        title: Text(label, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500)),
        trailing: Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
