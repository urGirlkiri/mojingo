// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:grimoji/features/settings/widgets/name_change_line.dart';
import 'package:grimoji/features/settings/widgets/settings_line.dart';
import 'package:grimoji/features/map/level_data_controller.dart';

import '../../widgets/custom_button.dart';
import '../../config/palette.dart';
import '../../widgets/responsive_screen.dart';
import 'controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const _gap = SizedBox(height: 60);

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsController>();
    final palette = context.watch<Palette>();

    return Scaffold(
      backgroundColor: palette.voidBlack,
      body: ResponsiveScreen(
        squarishMainArea: ListView(
          children: [
            _gap,
            Text(
              'Settings',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            _gap,
            const NameChangeLine('Name'),
            ValueListenableBuilder<bool>(
              valueListenable: settings.soundsOn,
              builder: (context, soundsOn, child) => SettingsLine(
                'Sound FX',
                Icon(soundsOn ? Icons.graphic_eq : Icons.volume_off),
                onSelected: settings.toggleSoundsOn,
              ),
            ),
            ValueListenableBuilder<bool>(
              valueListenable: settings.musicOn,
              builder: (context, musicOn, child) => SettingsLine(
                'Music',
                Icon(musicOn ? Icons.music_note : Icons.music_off),
                onSelected: settings.toggleMusicOn,
              ),
            ),
            SettingsLine(
              'Reset progress',
              const Icon(Icons.delete),
              onSelected: () {
                context.read<LevelDataController>().reset();

                final messenger = ScaffoldMessenger.of(context);
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      'Player progress has been reset.',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                );
              },
            ),
            _gap,
          ],
        ),
        rectangularMenuArea: CustomButton(
          onPressed: () {
            GoRouter.of(context).pop();
          },
          child: Text('Back', style: Theme.of(context).textTheme.bodyMedium),
        ),
      ),
    );
  }
}
