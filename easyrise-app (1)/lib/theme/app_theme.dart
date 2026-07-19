import 'package:flutter/material.dart';

/// EasyRise palette — soft mint green + soft pink, designed to feel calm
/// even at 6am. Nothing saturated or harsh; everything sits in the
/// "pastel, low-contrast, easy on sleepy eyes" range.
class AppColors {
  AppColors._();

  static const Color mint = Color(0xFFB8E6D0); // primary
  static const Color mintDeep = Color(0xFF6FBF9A); // primary buttons/text
  static const Color pink = Color(0xFFF6C9D6); // accent
  static const Color pinkDeep = Color(0xFFE8A0B8); // accent pressed
  static const Color cream = Color(0xFFFBF8F3); // background
  static const Color card = Color(0xFFFFFFFF);
  static const Color ink = Color(0xFF3A3D3B); // primary text, soft black
  static const Color inkFaint = Color(0xFF8B8F8C); // secondary text
  static const Color danger = Color(0xFFE39A9A);
}

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.cream,
      // Deliberately using the system default font (Roboto on Android) —
      // no bundled font files, keeps the app bundle small.
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.mintDeep,
        brightness: Brightness.light,
        primary: AppColors.mintDeep,
        secondary: AppColors.pinkDeep,
        surface: AppColors.card,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
            fontWeight: FontWeight.w800, color: AppColors.ink, fontSize: 32),
        headlineMedium: TextStyle(
            fontWeight: FontWeight.w700, color: AppColors.ink, fontSize: 24),
        bodyLarge: TextStyle(color: AppColors.ink, fontSize: 16, height: 1.4),
        bodyMedium: TextStyle(color: AppColors.inkFaint, fontSize: 14),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.cream,
        foregroundColor: AppColors.ink,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w800,
          color: AppColors.ink,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.mintDeep,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 28),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          textStyle: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
          elevation: 0,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        margin: EdgeInsets.zero,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.mintDeep
              : Colors.white,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.mint
              : const Color(0xFFE3E1DC),
        ),
      ),
      dividerColor: const Color(0xFFEFEBE4),
    );
  }
}
