import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grimoji/config/audio/audio_controller.dart';
import 'package:grimoji/config/audio/sounds.dart';
import 'package:grimoji/config/emojis.dart';
import 'package:grimoji/config/palette.dart';
import 'package:grimoji/widgets/emoji_widget.dart';
import 'package:grimoji/widgets/scroll_dialog.dart';
import 'package:provider/provider.dart';

class LevelQuitDialog extends StatelessWidget {
  final int level;

  const LevelQuitDialog({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: ScrollDialog(
        closeButton: GestureDetector(
          onTap: () {
            context.read<AudioController>().playSfx(SfxType.buttonTap);
            Navigator.of(context).pop();
          },
          child: Container(
            decoration: BoxDecoration(
              color: palette.twilight,
              shape: BoxShape.circle,
              border: Border.all(color: palette.mist, width: 3),
              boxShadow: [
                BoxShadow(
                  color: palette.voidBlack.withValues(alpha: 0.5),
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(Icons.close, color: palette.trueWhite, size: 48),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            EmojiWidget.lottie(
              path: Emojis.cryingCatFace.lottie,
              useDropShadow: true,
              size: 80,
            ),
            const SizedBox(height: 16),
            Text(
              "Quit Level?",
              style: GoogleFonts.eagleLake(
                color: palette.midnight,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Progress will be lost!",
              style: GoogleFonts.eagleLake(
                color: palette.twilight,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    context.read<AudioController>().playSfx(SfxType.buttonTap);
                    Navigator.of(context).pop();
                    GoRouter.of(context).go('/play/fail/$level');
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: palette.crimson,
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
                      "Quit",
                      style: GoogleFonts.eagleLake(
                        fontSize: 20,
                        color: palette.trueWhite,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: () {
                    context.read<AudioController>().playSfx(SfxType.buttonTap);
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
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
                      "Stay",
                      style: GoogleFonts.eagleLake(
                        fontSize: 20,
                        color: palette.mist,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
