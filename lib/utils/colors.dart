import 'package:flutter/material.dart';

class AppColors {
  // Light Theme Colors
  static const Color primary = Color(0xFF009688); // Teal 500
  static const Color primaryVariant = Color(0xFF00796B); // Teal 700
  static const Color primaryLight = Color(0xFF4DB6AC); // Teal 300
  static const Color secondary = Color(0xFF4CAF50); // Green 500
  static const Color secondaryVariant = Color(0xFF018786);
  static const Color secondaryLight = Color(0xFF81C784); // Green 300
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color error = Color(0xFFB00020);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onBackground = Color(0xFF000000);
  static const Color onSurface = Color(0xFF000000);
  static const Color onError = Color(0xFFFFFFFF);

  // Dark Theme Colors - Professional like YouTube/Facebook
  static const Color darkPrimary = Color(0xFF26D0CE); // Vibrant Teal
  static const Color darkPrimaryVariant = Color(0xFF4DD0E1); // Cyan 300
  static const Color darkSecondary = Color(0xFF69F0AE); // Vibrant Green
  static const Color darkSecondaryVariant = Color(0xFF00BFA5); // Teal Accent
  static const Color darkBackground = Color(
    0xFF0F0F0F,
  ); // True dark like YouTube
  static const Color darkSurface = Color(
    0xFF1C1C1E,
  ); // Card surface like iOS dark
  static const Color darkSurfaceVariant = Color(0xFF2C2C2E); // Elevated surface
  static const Color darkError = Color(0xFFFF6B6B); // Softer red
  static const Color darkOnPrimary = Color(0xFF000000);
  static const Color darkOnSecondary = Color(0xFF000000);
  static const Color darkOnBackground = Color(0xFFE8E8E8); // Softer white
  static const Color darkOnSurface = Color(0xFFE8E8E8);
  static const Color darkOnError = Color(0xFF000000);

  // Additional dark mode colors for better contrast
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFB0B0B0);
  static const Color darkTextTertiary = Color(0xFF808080);
  static const Color darkDivider = Color(0xFF2C2C2E);
  static const Color darkHover = Color(0xFF2C2C2E);

  // Glassmorphism colors
  static Color glassLight = Colors.white.withOpacity(0.9);
  static Color glassDark = Colors.white.withOpacity(0.08); // More subtle
  static Color glassBorderLight = Colors.white.withOpacity(0.5);
  static Color glassBorderDark = Colors.white.withOpacity(0.15); // More subtle

  static ThemeData toLightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primary,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.light(
        primary: primary,
        primaryContainer: primaryLight,
        secondary: secondary,
        secondaryContainer: secondaryLight,
        background: background,
        surface: surface,
        error: error,
        onPrimary: onPrimary,
        onSecondary: onSecondary,
        onBackground: onBackground,
        onSurface: onSurface,
        onError: onError,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primary,
        foregroundColor: onPrimary,
        elevation: 0,
      ),
    );
  }

  static ThemeData toDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: darkPrimary,
      scaffoldBackgroundColor: darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: darkPrimary,
        primaryContainer: darkPrimaryVariant,
        secondary: darkSecondary,
        secondaryContainer: darkSecondaryVariant,
        background: darkBackground,
        surface: darkSurface,
        surfaceContainerHighest: darkSurfaceVariant,
        error: darkError,
        onPrimary: darkOnPrimary,
        onSecondary: darkOnSecondary,
        onBackground: darkOnBackground,
        onSurface: darkOnSurface,
        onError: darkOnError,
      ),
      cardTheme: CardThemeData(
        color: darkSurface,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkSurface,
        foregroundColor: darkOnSurface,
        elevation: 0,
      ),
    );
  }

  // Get gradient colors based on theme
  static List<Color> getGradientColors(bool isDark) {
    if (isDark) {
      return [
        Color(0xFF1A1A1D), // Deep dark
        Color(0xFF1C1C1E), // Dark surface
        Color(0xFF0F0F0F), // True dark
      ];
    } else {
      return [primary, primaryVariant, secondary];
    }
  }

  // Get glassmorphic background color
  static Color getGlassBackground(bool isDark) {
    return isDark ? glassDark : glassLight;
  }

  // Get glassmorphic border color
  static Color getGlassBorder(bool isDark) {
    return isDark ? glassBorderDark : glassBorderLight;
  }

  // Get card/surface color
  static Color getSurfaceColor(bool isDark) {
    return isDark ? darkSurface : surface;
  }

  // Get text color by hierarchy
  static Color getTextPrimary(bool isDark) {
    return isDark ? darkTextPrimary : onSurface;
  }

  static Color getTextSecondary(bool isDark) {
    return isDark ? darkTextSecondary : Colors.grey[700]!;
  }

  static Color getTextTertiary(bool isDark) {
    return isDark ? darkTextTertiary : Colors.grey[500]!;
  }

  // Get divider color
  static Color getDivider(bool isDark) {
    return isDark ? darkDivider : Colors.grey[200]!;
  }

  // Get hover/pressed state color
  static Color getHoverColor(bool isDark) {
    return isDark ? darkHover : Colors.grey[100]!;
  }
}
