import 'package:flutter/material.dart';

class FilmbaseColors {
  static const canvas = Color(0xFF07080C);
  static const surface = Color(0xFF12141C);
  static const elevated = Color(0xFF1B1E28);
  static const accent = Color(0xFFE50914);
  static const gold = Color(0xFFF5C518);
  static const text = Color(0xFFF5F6FA);
  static const muted = Color(0x99F5F6FA);
  static const hairline = Color(0x14FFFFFF);
}

class FilmbaseTheme {
  static ThemeData get dark {
    return ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      scaffoldBackgroundColor: FilmbaseColors.canvas,
      primaryColor: FilmbaseColors.accent,
      colorScheme: const ColorScheme.dark(
        primary: FilmbaseColors.accent,
        secondary: FilmbaseColors.gold,
        surface: FilmbaseColors.surface,
        onSurface: FilmbaseColors.text,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: FilmbaseColors.text,
        titleTextStyle: TextStyle(
          color: FilmbaseColors.text,
          fontSize: 20,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.4,
        ),
      ),
      cardTheme: CardThemeData(
        color: FilmbaseColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: FilmbaseColors.hairline),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: FilmbaseColors.surface,
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.32)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: FilmbaseColors.hairline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: FilmbaseColors.hairline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: FilmbaseColors.accent, width: 1.5),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: FilmbaseColors.elevated,
        contentTextStyle: TextStyle(color: FilmbaseColors.text),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        backgroundColor: const Color(0xFF0E1016),
        indicatorColor: FilmbaseColors.accent.withValues(alpha: 0.18),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? FilmbaseColors.accent : Colors.white.withValues(alpha: 0.42),
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? FilmbaseColors.accent : Colors.white.withValues(alpha: 0.42),
          );
        }),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: FilmbaseColors.accent,
        foregroundColor: Colors.white,
        elevation: 6,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: FilmbaseColors.elevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: FilmbaseColors.hairline),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: FilmbaseColors.elevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: FilmbaseColors.hairline),
        ),
      ),
    );
  }
}
