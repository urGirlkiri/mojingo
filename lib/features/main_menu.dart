import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:grimoji/config/palette.dart';
import 'package:grimoji/widgets/neon_logo.dart';
import 'package:provider/provider.dart';

import '../config/audio/audio_controller.dart';
import '../config/audio/sounds.dart';
import '../widgets/pill_button.dart';
import '../widgets/responsive_screen.dart';
import 'settings/controller.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();
    final settingsController = context.watch<SettingsController>();
    final audioController = context.watch<AudioController>();

    return Scaffold(
      backgroundColor: palette.midnight,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/emo_2.png', fit: BoxFit.cover),
          ),
          ResponsiveScreen(
            squarishMainArea: LayoutBuilder(
              builder: (context, constraints) {
                final maxSize = constraints.maxWidth < constraints.maxHeight
                    ? constraints.maxWidth * 0.7
                    : constraints.maxHeight * 0.6;
                final imageSize = maxSize.clamp(150.0, 300.0);

                return SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: SizedBox(
                    height: constraints.maxHeight,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(height: imageSize * 0.1),
                            Image.asset(
                              'assets/icons/512x512.png',
                              fit: BoxFit.contain,
                              width: imageSize,
                              height: imageSize * 1.1,
                            ),
                            const SizedBox(height: 16),
                            NeonLogo(imageSize: imageSize),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            rectangularMenuArea: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  PillButton(
                    text: 'Play',
                    color: palette.twilight,
                    textColor: palette.mist,
                    fullWidth: false,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    borderRadius: 20,
                    borderColor: palette.magicCyan.withValues(alpha: .2),
                    borderWidth: 3,
                    onTap: () {
                      audioController.playSfx(SfxType.buttonTap);
                      GoRouter.of(context).go('/play');
                    },
                  ),
                  _gap,
                  PillButton(
                    text: 'Settings',
                    color: palette.twilight,
                    textColor: palette.mist,
                    fullWidth: false,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    borderRadius: 20,
                    borderColor: palette.magicCyan.withValues(alpha: .2),
                    borderWidth: 3,
                    onTap: () => GoRouter.of(context).push('/settings'),
                  ),
                  _gap,
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: ValueListenableBuilder<bool>(
                      valueListenable: settingsController.audioOn,
                      builder: (context, audioOn, child) {
                        return IconButton(
                          onPressed: settingsController.toggleAudioOn,
                          icon: Icon(
                            audioOn ? Icons.volume_up : Icons.volume_off,
                          ),
                        );
                      },
                    ),
                  ),
                  _gap,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static const _gap = SizedBox(height: 10);
}
