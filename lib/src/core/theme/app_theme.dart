import 'package:flutter/material.dart';

const emojiFontFallback = <String>[
  'Noto Color Emoji',
  'Apple Color Emoji',
  'Segoe UI Emoji',
  'Noto Emoji',
];

ThemeData buildAppTheme() {
  const baseTextColor = Color(0xFF191613);
  final colorScheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFFE8643D),
    brightness: Brightness.light,
    primary: const Color(0xFFE8643D),
    secondary: const Color(0xFFFCB736),
    surface: const Color(0xFFFFFBF5),
  );

  final textTheme = ThemeData.light().textTheme.apply(
    bodyColor: baseTextColor,
    displayColor: baseTextColor,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: const Color(0xFFFFF6EB),
    textTheme: textTheme.copyWith(
      displayLarge: textTheme.displayLarge?.copyWith(
        fontWeight: FontWeight.w800,
        letterSpacing: -1.8,
      ),
      displaySmall: textTheme.displaySmall?.copyWith(
        fontWeight: FontWeight.w800,
        letterSpacing: -1.2,
      ),
      headlineMedium: textTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.6,
      ),
      titleLarge: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
      titleMedium: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
      bodyLarge: textTheme.bodyLarge?.copyWith(height: 1.35),
      bodyMedium: textTheme.bodyMedium?.copyWith(height: 1.35),
    ),
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      side: BorderSide.none,
      selectedColor: const Color(0xFF191613),
      backgroundColor: const Color(0xFFF4E4D1),
      labelStyle: const TextStyle(fontWeight: FontWeight.w600),
      secondaryLabelStyle: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w700,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: Colors.white.withValues(alpha: 0.84),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      margin: EdgeInsets.zero,
    ),
  );
}
