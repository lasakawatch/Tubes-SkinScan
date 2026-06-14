// lib/screens/profile_tab.dart
// View (MVVM) - membaca dari AuthViewModel via Provider
// CRUD: Read (profil) + Update (edit profil)

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
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
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
                child: Center(child: Text(initials, style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white))),
              ),
              const SizedBox(height: 12),
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
              children: [const Text('Aplikasi Edukasi Dermatologi berbasis AI.\nMendeteksi 10 jenis kondisi kulit dengan akurasi 86%.')],
            );
          }),
          _MenuItem(icon: Icons.help_outline_rounded, label: 'Bantuan & FAQ', onTap: null),
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
