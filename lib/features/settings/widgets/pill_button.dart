import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grimoji/config/palette.dart';

class PillButton extends StatelessWidget {
  final String text;
  final Color color;
  final Palette palette;
  final VoidCallback onTap;

  const PillButton({
    super.key,
    required this.text,
    required this.color,
    required this.palette,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(40),
          border: Border.all(color: palette.trueWhite, width: 2),
          boxShadow: [
            BoxShadow(
              color: palette.voidBlack.withValues(alpha: 0.4),
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            text,
            style: GoogleFonts.eagleLake(
              fontSize: 22,
              color: palette.trueWhite,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  color: palette.voidBlack.withValues(alpha: 0.5),
                  offset: const Offset(1, 2),
                  blurRadius: 2,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
