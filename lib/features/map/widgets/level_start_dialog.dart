import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grimoji/config/levels.dart';
import 'package:grimoji/widgets/emoji_widget.dart';
import 'package:grimoji/widgets/scroll_dialog.dart';
import 'package:provider/provider.dart';

import 'package:grimoji/config/audio/audio_controller.dart';
import 'package:grimoji/config/audio/sounds.dart';
import 'package:grimoji/config/palette.dart';

class LevelStartDialog extends StatelessWidget {
  final GameLevel level;

  const LevelStartDialog({super.key, required this.level});

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
            Text(
              "Level ${level.number}",
              style: GoogleFonts.eagleLake(
                color: palette.midnight,
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            EmojiWidget.lottie(
              path: level.targetEmoji.lottie,
              useDropShadow: true,
              size: 120,
            ),

            GestureDetector(
              onTap: () {
                context.read<AudioController>().playSfx(SfxType.buttonTap);
                Navigator.of(context).pop();
                GoRouter.of(context).replace('/play/hint/${level.number}');
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
    );
  }
}
