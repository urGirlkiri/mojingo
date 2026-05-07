// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../logic/score.dart';
import '../../widgets/custom_button.dart';
import '../../config/palette.dart';
import '../../widgets/responsive_screen.dart';
import '../map/levels.dart';

class WinGameScreen extends StatefulWidget {
  final Score score;

  const WinGameScreen({super.key, required this.score});

  @override
  State<WinGameScreen> createState() => _WinGameScreenState();
}

class _WinGameScreenState extends State<WinGameScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        final nextLevelNumber = widget.score.level + 1;
        final hasNextLevel = gameLevels.any((level) => level.number == nextLevelNumber);
        
        if (hasNextLevel) {
          GoRouter.of(context).go('/play?autoOpen=$nextLevelNumber');
        } else {
          GoRouter.of(context).go('/play');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();

    const gap = SizedBox(height: 10);

    return Scaffold(
      backgroundColor: palette.twilight,
      body: ResponsiveScreen(
        squarishMainArea: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            gap,
            const Center(
              child: Text(
                'You won!',
              ),
            ),
            gap,
            Center(
              child: Text(
                'Score: ${widget.score.score}\n'
                'Time: ${widget.score.formattedTime}',
              ),
            ),
          ],
        ),
        rectangularMenuArea: CustomButton(
          onPressed: () {
            final nextLevelNumber = widget.score.level + 1;
            final hasNextLevel = gameLevels.any((level) => level.number == nextLevelNumber);
            
            if (hasNextLevel) {
              GoRouter.of(context).go('/play?autoOpen=$nextLevelNumber');
            } else {
              GoRouter.of(context).go('/play');
            }
          },
          child: const Text('Continue'),
        ),
      ),
    );
  }
}
