import 'package:flutter/material.dart';

/// PINC Network App Theme
/// Dark privacy-focused theme with cyan/green accents
class AppTheme {
  // Colors
  static const Color primaryDark = Color(0xFF0A0E14);
  static const Color secondaryDark = Color(0xFF121820);
  static const Color surfaceColor = Color(0xFF1A2028);
  static const Color cardColor = Color(0xFF232D38);
  
  static const Color accentCyan = Color(0xFF00D4AA);
  static const Color accentGreen = Color(0xFF00FF94);
  static const Color accentBlue = Color(0xFF4A90D9);
  
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8B9AAB);
  static const Color textTertiary = Color(0xFF5A6577);
  
  static const Color success = Color(0xFF00D4AA);
  static const Color warning = Color(0xFFFFB347);
  static const Color error = Color(0xFFFF6B6B);
  
  static const Color divider = Color(0xFF2A3441);

  // Gradients
  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF1A2028), Color(0xFF121820)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accentCyan, accentGreen],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient vpnGradient = LinearGradient(
    colors: [Color(0xFF00D4AA), Color(0xFF00FF94)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient walletGradient = LinearGradient(
    colors: [Color(0xFF4A90D9), Color(0xFF6BB3F0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Theme Data
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: accentCyan,
      scaffoldBackgroundColor: primaryDark,
      colorScheme: const ColorScheme.dark(
        primary: accentCyan,
        secondary: accentGreen,
        surface: surfaceColor,
        error: error,
        onPrimary: primaryDark,
        onSecondary: primaryDark,
        onSurface: textPrimary,
        onError: textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryDark,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: textPrimary),
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: secondaryDark,
        selectedItemColor: accentCyan,
        unselectedItemColor: textTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      cardTheme: CardTheme(
        color: cardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentCyan,
          foregroundColor: primaryDark,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: accentCyan,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: const BorderSide(color: accentCyan, width: 2),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accentCyan,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: accentCyan, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: const TextStyle(color: textTertiary),
        labelStyle: const TextStyle(color: textSecondary),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: textPrimary, fontSize: 32, fontWeight: FontWeight.bold),
        displayMedium: TextStyle(color: textPrimary, fontSize: 28, fontWeight: FontWeight.bold),
        displaySmall: TextStyle(color: textPrimary, fontSize: 24, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(color: textPrimary, fontSize: 20, fontWeight: FontWeight.w600),
        headlineSmall: TextStyle(color: textPrimary, fontSize: 18, fontWeight: FontWeight.w600),
        titleLarge: TextStyle(color: textPrimary, fontSize: 16, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(color: textPrimary, fontSize: 14, fontWeight: FontWeight.w500),
        bodyLarge: TextStyle(color: textPrimary, fontSize: 16),
        bodyMedium: TextStyle(color: textSecondary, fontSize: 14),
        bodySmall: TextStyle(color: textTertiary, fontSize: 12),
        labelLarge: TextStyle(color: textPrimary, fontSize: 14, fontWeight: FontWeight.w600),
      ),
      dividerTheme: const DividerThemeData(
        color: divider,
        thickness: 1,
      ),
      iconTheme: const IconThemeData(
        color: textSecondary,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: cardColor,
        contentTextStyle: const TextStyle(color: textPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      dialogTheme: DialogTheme(
        backgroundColor: secondaryDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: secondaryDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
    );
  }
}