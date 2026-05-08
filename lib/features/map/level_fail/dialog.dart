import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mojingo/config/emojis.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mojingo/config/audio/audio_controller.dart';
import 'package:mojingo/config/audio/sounds.dart';
import 'package:mojingo/config/palette.dart';
import 'package:mojingo/widgets/lottie_emoji_widget.dart';
import 'package:mojingo/widgets/scroll_dialog.dart';

class LevelFailDialog extends StatelessWidget {
  final int level;

  const LevelFailDialog({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.all(20),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          ScrollDialog(
            closeButton: GestureDetector(
              onTap: () {
                context.read<AudioController>().playSfx(SfxType.buttonTap);
                Navigator.of(context).pop();
                                GoRouter.of(context).go('/play');

              },
              child: Container(
                padding: const EdgeInsets.all(8),
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
                child: Icon(Icons.close, color: palette.mist, size: 48),
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  LottieEmojiWidget.lottie(
                    path: Emojis.fireBurst.lottie,
                    size: 90,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'The mixture exploded!',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.eagleLake(
                      color: palette.twilight,
                      fontSize: 28,
                    ),
                  ),
                  const SizedBox(height: 30),

                  GestureDetector(
                    onTap: () {
                      context.read<AudioController>().playSfx(SfxType.buttonTap);
                      Navigator.of(context).pop();
                      GoRouter.of(context).go('/play?autoOpen=$level');
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: palette.crimson,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: palette.midnight, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: palette.voidBlack.withValues(alpha: 0.6),
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        'Retry Level $level',
                        style: GoogleFonts.eagleLake(
                          fontSize: 20,
                          color: palette.trueWhite,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

