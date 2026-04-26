import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

final themeModeProvider = StateProvider<ThemeMode>((_) => ThemeMode.system);

class AppTheme {
  AppTheme._();

  static const Color _lightBackground = Color(0xFFF6F7FB);
  static const Color _darkBackground = Color(0xFF101827);
  static const Color _primary = Color(0xFF2D4CF5);
  static const Color _secondary = Color(0xFF40C4FF);
  static const Color _surface = Color(0xFFFFFFFF);
  static const Color _surfaceDark = Color(0xFF172A48);

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: _primary,
      onPrimary: Colors.white,
      secondary: _secondary,
      onSecondary: Colors.white,
      error: Color(0xFFEF5350),
      onError: Colors.white,
      surface: _surface,
      onSurface: Color(0xFF101827),
    ),
    scaffoldBackgroundColor: _lightBackground,
    cardTheme: CardThemeData(
      elevation: 0,
      color: _surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(22)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: Color(0xFFF1F3F8),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
        borderSide: BorderSide.none,
      ),
    ),
    textTheme: GoogleFonts.interTextTheme(
      const TextTheme(
        titleLarge: TextStyle(fontWeight: FontWeight.w700, fontSize: 24),
        bodyLarge: TextStyle(fontSize: 16, height: 1.4),
        bodyMedium: TextStyle(fontSize: 14, height: 1.4),
        titleMedium: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
      ),
    ),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: _lightBackground,
      foregroundColor: Color(0xFF101827),
      titleTextStyle: TextStyle(
        color: Color(0xFF101827),
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
      iconTheme: IconThemeData(color: Color(0xFF101827)),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme(
      brightness: Brightness.dark,
      primary: _primary,
      onPrimary: Colors.white,
      secondary: _secondary,
      onSecondary: Colors.black,
      error: Color(0xFFEF9A9A),
      onError: Colors.black,
      surface: _surfaceDark,
      onSurface: Colors.white,
    ),
    scaffoldBackgroundColor: _darkBackground,
    cardTheme: CardThemeData(
      elevation: 0,
      color: _surfaceDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(22)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: Color(0xFF192A46),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
        borderSide: BorderSide.none,
      ),
    ),
    textTheme: GoogleFonts.interTextTheme(
      const TextTheme(
        titleLarge: TextStyle(fontWeight: FontWeight.w700, fontSize: 24),
        bodyLarge: TextStyle(fontSize: 16, height: 1.4),
        bodyMedium: TextStyle(fontSize: 14, height: 1.4),
        titleMedium: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
      ),
    ),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: _darkBackground,
      foregroundColor: Colors.white,
      titleTextStyle: TextStyle(
        color: Color(0xFFFFFFFF),
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
      iconTheme: IconThemeData(color: Colors.white),
    ),
  );
}
