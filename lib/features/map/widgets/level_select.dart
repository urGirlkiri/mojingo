import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:mojingo/config/audio/audio_controller.dart';
import 'package:mojingo/config/audio/sounds.dart';
import 'package:mojingo/config/palette.dart';

import 'package:mojingo/utils/responsive.dart';

class LevelStartDialog extends StatelessWidget {
  final int level;
  final String targetEmoji;

  const LevelStartDialog({
    super.key,
    required this.level,
    required this.targetEmoji,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();
    final isLarge = context.isLargeScreen;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: SizedBox(
        width: 677,
        height: isLarge ? 818 : 400,

        child: Stack(
          alignment: Alignment.center,
          children: [
            Image.asset(
              'assets/images/level/scroll.png',
              fit: BoxFit.fitWidth,
              width: 677,
              height: 818,
            ),

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 50.0,
                vertical: 40.0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Level $level",
                    style: GoogleFonts.eagleLake(
                      color: palette.midnight,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      targetEmoji,
                      style: const TextStyle(fontSize: 80),
                    ),
                  ),
                  
                  GestureDetector(
                    onTap: () {
                      context.read<AudioController>().playSfx(
                        SfxType.buttonTap,
                      );
                      Navigator.of(context).pop(); 
                      GoRouter.of(
                        context,
                      ).go('/play/session/$level'); 
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: palette.twilight,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: palette.voidBlack, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: palette.voidBlack.withValues(alpha: 0.5),
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        "MIX IT",
                        style: GoogleFonts.eagleLake(
                          fontSize: 24,
                          color: palette.mist,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Positioned(
              top: isLarge ? 20 : 15,
              right: isLarge ? 80 : 28,
              child: GestureDetector(
                onTap: () {
                  context.read<AudioController>().playSfx(SfxType.buttonTap);
                  Navigator.of(context).pop();
                },

                child: Container(
                  decoration: BoxDecoration(
                    color: palette.crimson,
                    shape: BoxShape.circle,

                    border: Border.all(color: palette.voidBlack, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: palette.voidBlack.withValues(alpha: 0.5),
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(Icons.close, color: palette.mist, size: 24),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}
