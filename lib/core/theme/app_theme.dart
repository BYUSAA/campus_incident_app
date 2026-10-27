import 'package:flutter/material.dart';
class AppTheme {
  AppTheme._();
  static ThemeData get light => _make(Brightness.light);
  static ThemeData get dark => _make(Brightness.dark);
  static ThemeData _make(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    return ThemeData(useMaterial3: true, brightness: brightness,
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0055FF), brightness: brightness),
      scaffoldBackgroundColor: dark ? const Color(0xFF101116) : const Color(0xFFF6F7FB),
      appBarTheme: AppBarTheme(elevation: 0, backgroundColor: dark ? const Color(0xFF101116) : Colors.white),
      cardTheme: CardThemeData(elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
      inputDecorationTheme: InputDecorationTheme(border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true),
    );
  }
}
