import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grimoji/config/audio/audio_controller.dart';
import 'package:grimoji/config/audio/sounds.dart';
import 'package:grimoji/config/emojis.dart';
import 'package:grimoji/config/palette.dart';
import 'package:grimoji/widgets/emoji_widget.dart';
import 'package:grimoji/widgets/pill_button.dart';
import 'package:grimoji/widgets/scroll_dialog.dart';
import 'package:provider/provider.dart';

class QuitDialog extends StatelessWidget {
  final int level;

  const QuitDialog({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
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
                PillButton(
                  text: "Quit",
                  color: palette.crimson,
                  textColor: palette.trueWhite,
                  fullWidth: false,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  borderRadius: 20,
                  borderColor: palette.voidBlack,
                  borderWidth: 3,
                  onTap: () {
                    context.read<AudioController>().playSfx(SfxType.buttonTap);
                    Navigator.of(context).pop();
                    GoRouter.of(context).go('/play/lose/$level');
                  },
                ),
                const SizedBox(width: 16),
                PillButton(
                  text: "Stay",
                  color: palette.twilight,
                  textColor: palette.mist,
                  fullWidth: false,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  borderRadius: 20,
                  borderColor: palette.voidBlack,
                  borderWidth: 3,
                  onTap: () {
                    context.read<AudioController>().playSfx(SfxType.buttonTap);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
