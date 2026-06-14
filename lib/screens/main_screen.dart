import 'package:flutter/material.dart';
import 'home_tab.dart';
import 'news_tab.dart';
import 'history_tab.dart';
import 'profile_tab.dart';
import 'scan_screen.dart';
import '../theme.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _idx = 0;
  final _tabs = const [HomeTab(), NewsTab(), HistoryTab(), ProfileTab()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _tabs[_idx],
      floatingActionButton: Container(
        decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [BoxShadow(color: AppTheme.primaryColor.withValues(alpha: 0.35), blurRadius: 16, offset: const Offset(0, 6))]),
        child: FloatingActionButton(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ScanScreen())),
          backgroundColor: AppTheme.primaryColor,
          elevation: 0,
          shape: const CircleBorder(),
          child: const Icon(Icons.camera_alt_rounded, size: 28, color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, -4))]),
        child: BottomNavigationBar(
          currentIndex: _idx,
          onTap: (i) => setState(() => _idx = i),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home_rounded), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.school_outlined), activeIcon: Icon(Icons.school_rounded), label: 'Edukasi'),
            BottomNavigationBarItem(icon: Icon(Icons.history_outlined), activeIcon: Icon(Icons.history_rounded), label: 'Riwayat'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outlined), activeIcon: Icon(Icons.person_rounded), label: 'Profil'),
          ],
        ),
      ),
    );
  }
}
