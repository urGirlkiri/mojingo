import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'palette.dart';

class AppTheme {
  static ThemeData buildTheme(Palette palette) {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: palette.voidBlack, 
      
      colorScheme: ColorScheme.dark(
        primary: palette.slate,
        secondary: palette.mist,
        tertiary: palette.dusk,
        surface: palette.midnight,
        surfaceContainer: palette.twilight,
        error: palette.crimson,
        onPrimary: palette.trueWhite,
        onSurface: palette.moonlight,
        onSurfaceVariant: palette.moonlightSoft,
      ),
      
      textTheme: TextTheme(
        displayLarge: GoogleFonts.eagleLake(
          fontSize: 65, color: palette.mist, height: 1,
        ),
        headlineLarge: GoogleFonts.eagleLake(
          fontSize: 32, color: palette.moonlight, fontWeight: FontWeight.bold,
        ),
        bodyLarge: GoogleFonts.caudex(
          fontSize: 20, color: palette.moonlightSoft,
        ),
        bodyMedium: GoogleFonts.caudex(
          fontSize: 16, color: palette.moonlightSoft,
        ),
        bodySmall: GoogleFonts.caudex(
          fontSize: 12, color: palette.moonlightSoft,
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