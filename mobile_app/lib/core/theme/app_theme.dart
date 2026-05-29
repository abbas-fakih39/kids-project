import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // --- Nuxt Design System Colors Translated to Flutter ---
  static const Color navy = Color(0xFF1B3A57);
  static const Color bluePrimary = Color(0xFF3C82F5);
  static const Color lightBlue = Color(0xFFDDE9FE);
  static const Color offWhite = Color(0xFFF4F7FA);
  static const Color white = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF334155);
  static const Color textGrey = Color(0xFF9CA3AF);
  
  static const Color success = Color(0xFF22C55E);
  static const Color error = Color(0xFFEF4444);

  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: bluePrimary,
      scaffoldBackgroundColor: offWhite,
      colorScheme: const ColorScheme.light(
        primary: bluePrimary,
        secondary: navy,
        error: error,
        surface: white,
      ),
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: GoogleFonts.inter(
          fontSize: 26, 
          fontWeight: FontWeight.w800, 
          color: navy,
        ),
        displayMedium: GoogleFonts.inter(
          fontSize: 22, 
          fontWeight: FontWeight.w700, 
          color: navy,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16, 
          color: textDark,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14, 
          color: textDark,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: navy),
        titleTextStyle: TextStyle(
          color: navy, 
          fontSize: 22, 
          fontWeight: FontWeight.w800, 
          fontFamily: 'Inter',
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: bluePrimary,
          foregroundColor: white,
          minimumSize: const Size(double.infinity, 54),
          elevation: 4,
          shadowColor: bluePrimary.withValues(alpha: 0.35),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            fontFamily: 'Inter',
            letterSpacing: 0.3,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: white,
        hintStyle: const TextStyle(color: textGrey, fontSize: 15),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: bluePrimary, width: 2),
        ),
      ),
    );
  }
}
