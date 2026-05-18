import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:grimoji/features/audio/audio_controller.dart';
import 'package:grimoji/features/audio/sounds.dart';
import 'package:grimoji/config/palette.dart';
import 'package:grimoji/features/map/level_data_controller.dart';
import 'package:grimoji/features/settings/controller.dart';
import 'package:grimoji/features/settings/widgets/icon_toggle.dart';
import 'package:grimoji/features/settings/widgets/volume_slider.dart';
import 'package:grimoji/utils/responsive.dart';
import 'package:grimoji/widgets/pill_button.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsController>();
    final palette = context.watch<Palette>();
    final isLarge = context.isLargeScreen;

    return Scaffold(
      backgroundColor: palette.voidBlack,
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/emo.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Center(
            child: SizedBox(
              width: 677,
              height: isLarge ? 677 : null,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Image.asset(
                    'assets/images/scroll.png',
                    fit: isLarge ? BoxFit.fill : BoxFit.fitWidth,
                    width: 677,
                    height: isLarge ? 677 : null,
                  ),

                  Positioned(
                    top: isLarge ? -1 : -1,
                    right: isLarge ? -1 : -1,
                    child: GestureDetector(
                      onTap: () {
                        context.read<AudioController>().playSfx(SfxType.buttonTap);
                        GoRouter.of(context).pop();
                      },
                      child: Image.asset(
                        'assets/icons/app/close.png',
                        width: 60,
                        height: 60,
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 60.0,
                      vertical: 50.0,
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Settings',
                            textAlign: TextAlign.center,
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
                          ]),
                          builder: (context, child) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                IconToggle(
                                  imagePath: settings.soundsOn.value
                                      ? 'assets/icons/app/vibration_on.png'
                                      : 'assets/icons/app/vibration_off.png',
                                  isActive: settings.soundsOn.value && settings.audioOn.value,
                                  onTap: () {
                                    context.read<AudioController>().playSfx(SfxType.buttonTap);
                                    settings.toggleSoundsOn();
                                  },
                                ),
                                IconToggle(
                                  imagePath: settings.musicOn.value
                                      ? 'assets/icons/app/sfx_on.png'
                                      : 'assets/icons/app/sfx_off.png',
                                  isActive: settings.musicOn.value && settings.audioOn.value,
                                  onTap: () {
                                    context.read<AudioController>().playSfx(SfxType.buttonTap);
                                    settings.toggleMusicOn();
                                  },
                                ),
                                IconToggle(
                                  imagePath: settings.audioOn.value
                                      ? 'assets/icons/app/music_on.png'
                                      : 'assets/icons/app/music_off.png',
                                  isActive: settings.audioOn.value,
                                  onTap: () {
                                    context.read<AudioController>().playSfx(SfxType.buttonTap);
                                    settings.toggleAudioOn();
                                  },
                                ),
                              ],
                            );
                          },
                        ),

                        const SizedBox(height: 24),

                        ListenableBuilder(
                          listenable: Listenable.merge([
                            settings.soundsOn,
                            settings.musicOn,
                            settings.audioOn,
                            settings.sfxVolume,
                            settings.musicVolume,
                          ]),
                          builder: (context, child) {
                            return Column(
                              children: [
                                VolumeSlider(
                                  label: "SFX Volume",
                                  value: settings.sfxVolume.value,
                                  palette: palette,
                                  onChanged: (settings.soundsOn.value && settings.audioOn.value)
                                    ? (val) => settings.setSfxVolume(val)
                                    : null,
                                ),
                                const SizedBox(height: 16),
                                VolumeSlider(
                                  label: "Music Volume",
                                  value: settings.musicVolume.value,
                                  palette: palette,
                                  onChanged: (settings.musicOn.value && settings.audioOn.value)
                                    ? (val) => settings.setMusicVolume(val)
                                    : null,
                                ),
                              ],
                            );
                          },
                        ),

                        const SizedBox(height: 24),

                        PillButton(
                          text: "Reset Progress",
                          color: palette.crimson,
                          onTap: () async {
                            context.read<AudioController>().playSfx(SfxType.buttonTap);
                            await context.read<LevelDataController>().reset();
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: palette.midnight,
                                content: Center(
                                  child: Text(
                                    'Player progress has been reset.',
                                    style: GoogleFonts.eagleLake(color: palette.trueWhite),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ));
  }
}
