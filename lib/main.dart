// lib/main.dart
// Entry point SkinScan - dengan MultiProvider untuk MVVM

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme.dart';
import 'screens/login_screen.dart';
import 'screens/main_screen.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/scan_viewmodel.dart';
import 'viewmodels/history_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp();
  }
  runApp(const SkinScanApp());
}

class SkinScanApp extends StatelessWidget {
  const SkinScanApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MultiProvider: mendaftarkan semua ViewModel untuk MVVM
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => ScanViewModel()),
        ChangeNotifierProvider(create: (_) => HistoryViewModel()),
      ],
      child: MaterialApp(
        title: 'SkinScan',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        home: const SplashScreen(),
      ),
    );
  }
}

// ── Splash Screen ──
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _fade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _slide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
    _checkAuth();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    final user = FirebaseAuth.instance.currentUser;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => user != null ? const MainScreen() : const LoginScreen(),
        transitionsBuilder: (_, animation, __, child) => FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [AppTheme.primaryColor, AppTheme.primaryDark, Color(0xFF0D3B2E)],
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fade,
            child: SlideTransition(
              position: _slide,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: const Icon(Icons.biotech_rounded, size: 72, color: Colors.white),
                ),
                const SizedBox(height: 28),
                const Text('SkinScan', style: TextStyle(fontSize: 38, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1)),
                const SizedBox(height: 8),
                Text('Edukasi Dermatologi Berbasis AI', style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.7))),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)),
                  child: Text('Model Akurasi 86% · 10 Kelas Penyakit', style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.85))),
                ),
                const SizedBox(height: 48),
                SizedBox(
                  width: 28, height: 28,
                  child: CircularProgressIndicator(color: Colors.white.withValues(alpha: 0.7), strokeWidth: 2.5),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
