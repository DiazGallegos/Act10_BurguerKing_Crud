import 'package:flutter/material.dart';

// ─── BK Brand Colors ──────────────────────────────────────────────────────────
class BKColors {
  static const red = Color(0xFFD62300);       // BK Red
  static const yellow = Color(0xFFF5A623);    // Mustard Yellow
  static const darkYellow = Color(0xFFE8940B);
  static const brown = Color(0xFF4A2500);     // Grilled Brown
  static const cream = Color(0xFFFFF8F0);
  static const darkBg = Color(0xFF1A0A00);
  static const cardBg = Color(0xFF2D1200);
  static const surface = Color(0xFF3D1A00);
  static const textPrimary = Color(0xFFFFF8F0);
  static const textSecondary = Color(0xFFBB8860);
  static const success = Color(0xFF4CAF50);
  static const danger = Color(0xFFE53935);
  static const greyText = Color(0xFF9E9E9E);
}

class BKTheme {
  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: BKColors.darkBg,
        colorScheme: const ColorScheme.dark(
          primary: BKColors.red,
          secondary: BKColors.yellow,
          surface: BKColors.cardBg,
          error: BKColors.danger,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: BKColors.darkBg,
          foregroundColor: BKColors.textPrimary,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w900,
            fontSize: 22,
            color: BKColors.yellow,
            letterSpacing: 1.5,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: BKColors.red,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            textStyle: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
              letterSpacing: 1.2,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: BKColors.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: BKColors.brown),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: BKColors.brown),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: BKColors.yellow, width: 2),
          ),
          labelStyle: const TextStyle(color: BKColors.textSecondary),
          hintStyle: const TextStyle(color: BKColors.textSecondary),
          prefixIconColor: BKColors.yellow,
        ),
        cardTheme: CardThemeData(
          color: BKColors.cardBg,
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: BKColors.surface,
          contentTextStyle: TextStyle(color: BKColors.textPrimary),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: BKColors.red,
          foregroundColor: Colors.white,
        ),
        chipTheme: ChipThemeData(
          backgroundColor: BKColors.surface,
          selectedColor: BKColors.yellow,
          labelStyle: const TextStyle(color: BKColors.textPrimary, fontWeight: FontWeight.bold),
          side: const BorderSide(color: BKColors.brown),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: BKColors.cardBg,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
      );
}
