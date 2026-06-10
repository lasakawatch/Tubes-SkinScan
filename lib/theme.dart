import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF2E7D5B);
  static const Color primaryLight = Color(0xFFE8F5E9);
  static const Color primaryDark = Color(0xFF1B5E20);
  static const Color accentColor = Color(0xFF66BB6A);
  static const Color backgroundColor = Color(0xFFF5F9F6);
  static const Color cardColor = Colors.white;
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color errorColor = Color(0xFFE53935);
  static const Color warningColor = Color(0xFFF59E0B);
  static const Color successColor = Color(0xFF10B981);
  static const Color infoColor = Color(0xFF3B82F6);

  static Color severityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'tinggi': return errorColor;
      case 'sedang': return warningColor;
      case 'rendah': return successColor;
      default: return infoColor;
    }
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: primaryColor, primary: primaryColor, secondary: accentColor, surface: backgroundColor, error: errorColor),
      scaffoldBackgroundColor: backgroundColor,
      textTheme: GoogleFonts.poppinsTextTheme(),
      appBarTheme: AppBarTheme(backgroundColor: primaryColor, foregroundColor: Colors.white, elevation: 0, centerTitle: true, titleTextStyle: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
      elevatedButtonTheme: ElevatedButtonThemeData(style: ElevatedButton.styleFrom(backgroundColor: primaryColor, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0, textStyle: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600))),
      outlinedButtonTheme: OutlinedButtonThemeData(style: OutlinedButton.styleFrom(foregroundColor: primaryColor, side: const BorderSide(color: primaryColor), padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), textStyle: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600))),
      inputDecorationTheme: InputDecorationTheme(filled: true, fillColor: Colors.white, contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade200)), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade200)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: primaryColor, width: 2)), labelStyle: GoogleFonts.poppins(color: textSecondary)),
      cardTheme: CardThemeData(color: cardColor, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade100))),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(backgroundColor: Colors.white, selectedItemColor: primaryColor, unselectedItemColor: textSecondary, type: BottomNavigationBarType.fixed, elevation: 8),
    );
  }
}
