import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {

  // Modern Color Palette
  static const Color primary = Color(0xFF6C5CE7);
  static const Color secondary = Color(0xFFA29BFE);
  static const Color accent = Color(0xFF00CEFF);
  static const Color dark = Color(0xFF2D3436);
  static const Color light = Color(0xFFF5F6FA);
  static const Color success = Color(0xFF00B894);
  static const Color warning = Color(0xFFFDCB6E);
  static const Color error = Color(0xFFD63031);
  static const Color info = Color(0xFF0984E3);

  // Light Theme
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: primary,
    colorScheme: const ColorScheme.light(
      primary: primary,
      secondary: secondary,
      surface: Colors.white,
      background: light,
      error: error,
    ),
    scaffoldBackgroundColor: light,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      iconTheme: const IconThemeData(color: dark),
      titleTextStyle: GoogleFonts.poppins(
        color: dark,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    textTheme: GoogleFonts.poppinsTextTheme().copyWith(
      headlineLarge: GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: dark,
      ),
      headlineMedium: GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: dark,
      ),
      bodyLarge: GoogleFonts.poppins(
        fontSize: 16,
        color: dark.withOpacity(0.8),
      ),
      bodyMedium: GoogleFonts.poppins(
        fontSize: 14,
        color: dark.withOpacity(0.6),
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    buttonTheme: ButtonThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(vertical: 16),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(
        vertical: 16,
        horizontal: 20,
      ),
    ),
  );

  // Dark Theme
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: primary,
    colorScheme: const ColorScheme.dark(
      primary: primary,
      secondary: secondary,
      surface: dark,
      background: Color(0xFF1E1E1E),
      error: error,
    ),
    scaffoldBackgroundColor: const Color(0xFF121212),
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFF1E1E1E),
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.poppins(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    textTheme: GoogleFonts.poppinsTextTheme().copyWith(
      headlineLarge: GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      headlineMedium: GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      bodyLarge: GoogleFonts.poppins(
        fontSize: 16,
        color: Colors.white.withOpacity(0.9),
      ),
      bodyMedium: GoogleFonts.poppins(
        fontSize: 14,
        color: Colors.white.withOpacity(0.7),
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: const Color(0xFF1E1E1E),
    ),
    buttonTheme: ButtonThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[600]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[600]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.blue, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(
        vertical: 12,
        horizontal: 16,
      ),
      fillColor: const Color(0xFF1E1E1E),
      filled: true,
    ),
  );

  // Custom text styles that can be used throughout the app
  static TextStyle get headlineStyle => GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  static TextStyle get subtitleStyle => GoogleFonts.roboto(
    fontSize: 16,
    color: Colors.grey,
  );

  static TextStyle get buttonTextStyle => GoogleFonts.roboto(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );

  // Custom colors
  static Color get successColor => Colors.green;
  static Color get warningColor => Colors.orange;
  static Color get infoColor => Colors.blue;
  static Color get errorColor => Colors.red;

  // Custom shadows
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  // Custom border radius
  static BorderRadius get cardBorderRadius => BorderRadius.circular(12);
  static BorderRadius get buttonBorderRadius => BorderRadius.circular(8);
  static BorderRadius get inputBorderRadius => BorderRadius.circular(8);

  // Custom padding
  static EdgeInsets get defaultPadding => const EdgeInsets.all(16);
  static EdgeInsets get horizontalPadding => const EdgeInsets.symmetric(horizontal: 16);
  static EdgeInsets get verticalPadding => const EdgeInsets.symmetric(vertical: 16);

  // Animation durations
  static Duration get quickAnimationDuration => const Duration(milliseconds: 200);
  static Duration get mediumAnimationDuration => const Duration(milliseconds: 350);
  static Duration get longAnimationDuration => const Duration(milliseconds: 500);

  // Helper method to get appropriate text color for a background
  static Color textColorForBackground(Color background) {
    return background.computeLuminance() > 0.5 ? Colors.black : Colors.white;
  }
}