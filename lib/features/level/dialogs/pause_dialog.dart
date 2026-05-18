import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grimoji/features/audio/audio_controller.dart';
import 'package:grimoji/features/audio/sounds.dart';
import 'package:grimoji/config/emojis.dart';
import 'package:grimoji/config/palette.dart';
import 'package:grimoji/config/routes.dart';
import 'package:grimoji/features/settings/dialog.dart';
import 'package:grimoji/widgets/emoji_widget.dart';
import 'package:grimoji/widgets/pill_button.dart';
import 'package:grimoji/widgets/scroll_dialog.dart';
import 'package:provider/provider.dart';

class PauseDialog extends StatelessWidget {
  final int level;

  const PauseDialog({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();
    final screenSize = MediaQuery.sizeOf(context);
    final isLarge = screenSize.width > 400;


    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: ScrollDialog(
        leftButton: GestureDetector(
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
        rightButton: GestureDetector(
          onTap: () {
            context.read<AudioController>().playSfx(SfxType.buttonTap);
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => SettingsDialog(level: level),
            );
          },
          child: Image.asset(
            'assets/icons/app/settings.png',
            width: 80,
            height: 80,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            EmojiWidget.lottie(
              path: Emojis.alienMonster.lottie,
              useDropShadow: true,
              size: isLarge?  100 : 70,
            ),
            Text(
              "The Game is Paused",
              style: GoogleFonts.eagleLake(
                color: palette.midnight,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
              const SizedBox(height: 12),
            Text(
              "Take a break, then get back to it!",
              style: GoogleFonts.eagleLake(
                color: palette.twilight,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: isLarge ? 32 : 12),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 12,
              children: [
                PillButton(
                  text: "Quit",
                  color: palette.crimson,
                  textColor: palette.trueWhite,
                  fullWidth: false,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  borderRadius: 20,
                  borderColor: palette.voidBlack,
                  borderWidth: 3,
                  onTap: () {
                    context.read<AudioController>().playSfx(SfxType.buttonTap);
                    Navigator.of(context).pop();
                    GoRouter.of(context).goNamed(
                      Routes.levelFail,
                      pathParameters: {'level': level.toString()},
                    );
                  },
                ),
                PillButton(
                  text: "Resume",
                  color: palette.twilight,
                  textColor: palette.mist,
                  fullWidth: false,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
      ),
    );
  }
}
