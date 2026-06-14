// lib/screens/register_screen.dart
// View (MVVM) - RegisterScreen menggunakan AuthViewModel

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../theme.dart';
import 'main_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  bool _obscure = true;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameCtrl.dispose(); _emailCtrl.dispose(); _passCtrl.dispose(); _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    final vm = context.read<AuthViewModel>();
    final ok = await vm.register(
      _nameCtrl.text.trim(),
      _emailCtrl.text.trim(),
      _passCtrl.text.trim(),
      _phoneCtrl.text.trim(),
    );

    if (!mounted) return;
    if (ok) {
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const MainScreen()), (r) => false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(vm.errorMessage ?? 'Registrasi gagal', style: GoogleFonts.poppins()),
        backgroundColor: AppTheme.errorColor, behavior: SnackBarBehavior.floating,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthViewModel>().isLoading;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [AppTheme.primaryColor, AppTheme.primaryDark, Color(0xFF0D3B2E)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // ── Header ──
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
                  child: Row(children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Buat Akun', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                      Text('Daftar untuk mulai belajar', style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70)),
                    ]),
                  ]),
                ),

                // ── Form Card ──
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(28),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF5F9F6),
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const SizedBox(height: 8),

                      // Nama
                      TextFormField(
                        controller: _nameCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Nama Lengkap',
                          prefixIcon: Icon(Icons.person_outline_rounded, color: AppTheme.primaryColor),
                        ),
                        validator: (v) => v == null || v.isEmpty ? 'Nama tidak boleh kosong' : null,
                      ),
                      const SizedBox(height: 14),

                      // Email
                      TextFormField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          hintText: 'email@example.com',
                          prefixIcon: Icon(Icons.email_outlined, color: AppTheme.primaryColor),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Email tidak boleh kosong';
                          if (!v.contains('@')) return 'Format email tidak valid';
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      // No HP
                      TextFormField(
                        controller: _phoneCtrl,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Nomor HP',
                          hintText: '08xxxxxxxxxx',
                          prefixIcon: Icon(Icons.phone_outlined, color: AppTheme.primaryColor),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Password
                      TextFormField(
                        controller: _passCtrl,
                        obscureText: _obscure,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppTheme.primaryColor),
                          suffixIcon: IconButton(
                            icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppTheme.textSecondary),
                            onPressed: () => setState(() => _obscure = !_obscure),
                          ),
                        ),
                        validator: (v) => v == null || v.length < 6 ? 'Password minimal 6 karakter' : null,
                      ),
                      const SizedBox(height: 28),

                      // Tombol Daftar
                      SizedBox(
                        width: double.infinity, height: 54,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _register,
                          child: isLoading
                              ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                              : Text('Buat Akun', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
                        ),
                      ),
                      const SizedBox(height: 20),

                      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Text('Sudah punya akun? ', style: GoogleFonts.poppins(color: AppTheme.textSecondary, fontSize: 13)),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Text('Masuk', style: GoogleFonts.poppins(color: AppTheme.primaryColor, fontWeight: FontWeight.w600, fontSize: 13)),
                        ),
                      ]),
                      const SizedBox(height: 20),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
