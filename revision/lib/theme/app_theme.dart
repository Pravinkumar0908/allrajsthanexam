import 'package:flutter/material.dart';

class AppTheme {
  // Premium palette - White Background & Solid Indigo theme
  static const Color primary = Color(0xFF4F46E5); // Indigo
  static const Color primaryLight = Color(0xFFEEF2FF); // Soft indigo tint
  static const Color secondary = Color(0xFF0EA5E9); // Sky blue
  static const Color background = Color(0xFFFFFFFF); // Solid White Background
  static const Color surface = Color(0xFFFFFFFF); // White Surface
  static const Color textPrimary = Color(0xFF0F172A); // Slate 900 (Deep charcoal)
  static const Color textSecondary = Color(0xFF475569); // Slate 600
  static const Color textHint = Color(0xFF94A3B8); // Slate 400
  static const Color border = Color(0xFFE2E8F0); // Slate 200 (Clean subtle borders)
  static const Color success = Color(0xFF10B981); // Emerald
  static const Color error = Color(0xFFEF4444); // Red
  static const Color warning = Color(0xFFF59E0B); // Amber
  static const Color cardShadow = Color(0x08000000); // Super subtle shadow

  // Category colors - Premium, highly coordinated
  static const List<Color> categoryColors = [
    Color(0xFF4F46E5), // Indigo
    Color(0xFF0EA5E9), // Sky Blue
    Color(0xFF10B981), // Emerald
    Color(0xFFF59E0B), // Amber
    Color(0xFFEC4899), // Pink
    Color(0xFF8B5CF6), // Purple
    Color(0xFFEF4444), // Red
    Color(0xFF14B8A6), // Teal
  ];

  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
          surface: surface,
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: textPrimary,
            fontSize: 22, // Increased font size
            fontWeight: FontWeight.w700,
          ),
          iconTheme: IconThemeData(color: textPrimary),
        ),
        cardTheme: CardThemeData(
          color: surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: border, width: 1.0), // Slightly thicker cleaner border
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: const TextStyle(
              fontSize: 18, // Increased font size
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
}
