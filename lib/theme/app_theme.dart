import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF3157D5);
  static const purple = Color(0xFF7B61D1);
  static const success = Color(0xFF1E9E5A);
  static const warning = Color(0xFFE08A00);
  static const danger = Color(0xFFD9534F);

  static const heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, purple],
  );

  static Color forType(String type) {
    switch (type) {
      case 'Internship':
        return primary;
      case 'Job':
        return success;
      case 'Hackathon':
        return warning;
      default:
        return purple;
    }
  }

  static Color forMatch(int percent) {
    if (percent >= 70) return success;
    if (percent >= 40) return warning;
    return danger;
  }

  static Color forProgress(int progress) {
    if (progress >= 75) return success;
    if (progress >= 50) return primary;
    if (progress >= 30) return warning;
    return danger;
  }
}

class AppTheme {
  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: brightness,
    );
    final surface = dark ? const Color(0xFF1C2040) : Colors.white;
    final chipBg = dark ? const Color(0xFF2A2F5A) : const Color(0xFFE9EDFF);

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor:
          dark ? const Color(0xFF0E1124) : const Color(0xFFE9EDFF),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: scheme.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shadowColor: AppColors.primary.withValues(alpha: 0.14),
        surfaceTintColor: Colors.transparent,
        color: surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: scheme.primaryContainer,
        elevation: 8,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: chipBg,
        side: BorderSide.none,
        selectedColor: scheme.primaryContainer,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
    );
  }
}
