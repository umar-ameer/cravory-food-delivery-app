import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFF00AEEF);
  static const Color secondary = Color(0xFF102A3A);

  static const Color background = Color(0xFF071015);
  static const Color surface = Color(0xFF101A20);
  static const Color cardColor = Color(0xFF111E25);

  static const Color darkText = Color(0xFFF4F8FA);
  static const Color lightText = Color(0xFF9BAAB3);
  static const Color borderColor = Color(0xFF22313A);

  static const Color success = Color(0xFF34C759);
  static const Color danger = Color(0xFFFF453A);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.dark,
        primary: primary,
        secondary: secondary,
        background: background,
        surface: surface,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: false,
        foregroundColor: darkText,
        surfaceTintColor: Colors.transparent,
      ),
      fontFamily: 'Roboto',
      textTheme: const TextTheme(
        bodyMedium: TextStyle(
          color: darkText,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        hintStyle: const TextStyle(
          color: lightText,
          fontSize: 14,
        ),
        prefixIconColor: lightText,
        suffixIconColor: lightText,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: borderColor,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: borderColor,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: primary,
            width: 1.4,
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: secondary,
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: darkText,
          ),
        ),
        iconTheme: WidgetStateProperty.all(
          const IconThemeData(
            color: darkText,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }
}