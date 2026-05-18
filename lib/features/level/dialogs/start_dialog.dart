import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grimoji/config/levels/game_level.dart';
import 'package:grimoji/features/audio/audio_controller.dart';
import 'package:grimoji/features/audio/sounds.dart';
import 'package:grimoji/config/palette.dart';
import 'package:grimoji/config/routes.dart';
import 'package:grimoji/widgets/emoji_widget.dart';
import 'package:grimoji/widgets/pill_button.dart';
import 'package:grimoji/widgets/scroll_dialog.dart';
import 'package:provider/provider.dart';

class LevelStartDialog extends StatelessWidget {
  final GameLevel level;

  const LevelStartDialog({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: EdgeInsets.all(0),
      child: ScrollDialog(
        rightButton: GestureDetector(
          onTap: () {
            context.read<AudioController>().playSfx(SfxType.buttonTap);
            Navigator.of(context).pop();
          },
          child: Image.asset(
            'assets/icons/app/close.png',
            width: 80,
            height: 80,
          ),
        ),
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
          child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          
          children: [
            Text(
              "Level ${level.number}",
              textAlign: TextAlign.center,
              style: GoogleFonts.eagleLake(
                color: palette.midnight,
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            EmojiWidget.lottie(
              path: level.targetEmoji.lottie,
              useDropShadow: true,
              size: 100,
            ),
            const SizedBox(height: 24),
            PillButton(
              text: "MIX IT",
              color: palette.twilight,
              textColor: palette.mist,
              fullWidth: false,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              borderRadius: 20,
              borderColor: palette.voidBlack,
              borderWidth: 3,
              onTap: () {
                context.read<AudioController>().playSfx(SfxType.buttonTap);
                Navigator.of(context).pop();
                GoRouter.of(context).replaceNamed(
                  Routes.levelHint,
                  pathParameters: {'level': level.number.toString()},
                );
              },
            ),
          ],
                    ),
        ),
      ),
    );
  }
}
