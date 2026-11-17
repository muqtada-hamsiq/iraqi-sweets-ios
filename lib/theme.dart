import 'package:flutter/material.dart';

/// Luxurious gold + deep brown Iraqi theme. No placeholder colours.
class SweetsTheme {
  static const Color gold = Color(0xFFC9A227);
  static const Color goldLight = Color(0xFFE8C766);
  static const Color deepBrown = Color(0xFF1A120B);
  static const Color panelBrown = Color(0xFF2A1D12);
  static const Color cream = Color(0xFFFFF6E0);
  static const Color softCream = Color(0xFFD9C39A);

  static ThemeData get theme {
    const colorScheme = ColorScheme.dark(
      primary: gold,
      secondary: goldLight,
      surface: panelBrown,
    );
    return ThemeData(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: deepBrown,
      useMaterial3: true,
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: cream, fontWeight: FontWeight.bold),
        displayMedium: TextStyle(color: cream, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(color: cream, fontWeight: FontWeight.bold),
        titleLarge: TextStyle(color: cream, fontWeight: FontWeight.bold),
        titleMedium: TextStyle(color: cream, fontWeight: FontWeight.bold),
        bodyLarge: TextStyle(color: cream),
        bodyMedium: TextStyle(color: cream),
        bodySmall: TextStyle(color: softCream),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: gold,
          foregroundColor: Colors.black,
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: deepBrown,
        foregroundColor: cream,
        centerTitle: true,
      ),
    );
  }
}
