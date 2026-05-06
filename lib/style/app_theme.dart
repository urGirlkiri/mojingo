import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'palette.dart';

class AppTheme {
  static ThemeData buildTheme(Palette palette) {
    return ThemeData.from(
      colorScheme: ColorScheme.fromSeed(
        seedColor: palette.darkPen,
        surface: palette.backgroundMain,
      ),
      useMaterial3: true,
    ).copyWith(
      textTheme: TextTheme(
        displayLarge: GoogleFonts.eagleLake(
          fontSize: 65, color: palette.pen, height: 1,
        ),
        headlineLarge: GoogleFonts.eagleLake(
          fontSize: 32, color: palette.inkFullOpacity, fontWeight: FontWeight.bold,
        ),
        bodyLarge: GoogleFonts.caudex(
          fontSize: 20, color: palette.ink,
        ),
        bodyMedium: GoogleFonts.caudex(
          fontSize: 16, color: palette.ink,
        ),
        bodySmall: GoogleFonts.caudex(
          fontSize: 12, color: palette.ink,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          textStyle: GoogleFonts.eagleLake(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
    );
  }
}