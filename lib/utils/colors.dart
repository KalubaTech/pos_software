import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF009688); // Teal 500
  static const Color primaryVariant = Color(0xFF00796B); // Teal 700
  static const Color secondary = Color(0xFF4CAF50); // Green 500
  static const Color secondaryVariant = Color(0xFF018786);
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color error = Color(0xFFB00020);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onBackground = Color(0xFF000000);
  static const Color onSurface = Color(0xFF000000);
  static const Color onError = Color(0xFFFFFFFF);

  static ThemeData toDarkTheme() {
    // Material Design dark theme color system
    // Using lighter shades for dark theme primary/secondary
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: const Color(0xFF4DB6AC), // Teal 300
      primaryColorLight: const Color(0xFF00796B), // primaryVariant
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF4DB6AC), // Teal 300
        secondary: Color(0xFF81C784), // Green 300
        background: Color(0xFF121212), // background
        surface: Color(0xFF121212), // surface
        error: Color(0xFFCF6679), // error
        onPrimary: Color(0xFF000000), // onPrimary (on Teal 300)
        onSecondary: Color(0xFF000000), // onSecondary (on Green 300)
        onBackground: Color(0xFFFFFFFF), // onBackground
        onSurface: Color(0xFFFFFFFF), // onSurface
        onError: Color(0xFF000000), // onError
      ),
    );
  }
}