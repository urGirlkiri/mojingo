import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grimoji/config/audio/audio_controller.dart';
import 'package:grimoji/config/audio/sounds.dart';
import 'package:grimoji/config/palette.dart';
import 'package:grimoji/features/settings/controller.dart';
import 'package:grimoji/features/settings/widgets/icon_toggle.dart';
import 'package:grimoji/features/settings/widgets/pill_button.dart';
import 'package:grimoji/features/settings/widgets/volume_slider.dart';
import 'package:grimoji/widgets/scroll_dialog.dart';
import 'package:provider/provider.dart';

class SettingsDialog extends StatelessWidget {
  final int level;

  const SettingsDialog({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();
    final settings = context.read<SettingsController>();

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
            width: 60,
            height: 60,
          ),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Settings",
                style: GoogleFonts.eagleLake(
                  color: palette.midnight,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),
              ListenableBuilder(
                listenable: Listenable.merge([
                  settings.audioOn,
                  settings.soundsOn,
                  settings.musicOn,
                  settings.sfxVolume,
                  settings.musicVolume,
                ]),
                builder: (context, child) {
                  return Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconToggle(
                            imagePath: settings.soundsOn.value
                                ? 'assets/icons/app/vibration_on.png'
                                : 'assets/icons/app/vibration_off.png',
                            isActive: settings.soundsOn.value && settings.audioOn.value,
                            onTap: () {
                              context.read<AudioController>().playSfx(
                                SfxType.buttonTap,
                              );
                              settings.toggleSoundsOn();
                            },
                          ),
                          IconToggle(
                            imagePath: settings.musicOn.value
                                ? 'assets/icons/app/sfx_on.png'
                                : 'assets/icons/app/sfx_off.png',
                            isActive: settings.musicOn.value && settings.audioOn.value,
                            onTap: () {
                              context.read<AudioController>().playSfx(
                                SfxType.buttonTap,
                              );
                              settings.toggleMusicOn();
                            },
                          ),
                          IconToggle(
                            imagePath: settings.audioOn.value
                                ? 'assets/icons/app/music_on.png'
                                : 'assets/icons/app/music_off.png',
                            isActive: settings.audioOn.value,
                            onTap: () {
                              context.read<AudioController>().playSfx(
                                SfxType.buttonTap,
                              );
                              settings.toggleAudioOn();
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      VolumeSlider(
                        label: "SFX Volume",
                        value: settings.sfxVolume.value,
                        palette: palette,
                        onChanged: (settings.soundsOn.value && settings.audioOn.value) ? (val) {
                          settings.setSfxVolume(val);
                        } : null,
                      ),
                      const SizedBox(height: 16),
                      VolumeSlider(
                        label: "Music Volume",
                        value: settings.musicVolume.value,
                        palette: palette,
                        onChanged: (settings.musicOn.value && settings.audioOn.value) ? (val) {
                          settings.setMusicVolume(val);
                        } : null,
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 32),
              const SizedBox(height: 40),
              PillButton(
                text: "Quit level",
                color: palette.crimson,
                palette: palette,
                onTap: () {
                  context.read<AudioController>().playSfx(SfxType.buttonTap);
                  Navigator.of(context).pop();
                  GoRouter.of(context).go('/play/fail/$level');
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
