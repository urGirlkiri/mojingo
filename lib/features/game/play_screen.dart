// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart' hide Level;
import 'package:mojingo/features/map/level_data_controller.dart';
import 'package:provider/provider.dart';

import '../../config/audio/audio_controller.dart';
import '../../config/audio/sounds.dart';
import 'logic/level_state.dart';
import 'logic/levels.dart';
import 'widgets/confetti.dart';
import '../../widgets/custom_button.dart';
import '../../config/palette.dart';
import 'widgets/game_widget.dart';

/// This widget defines the entirety of the screen that the player sees when
/// they are playing a level.
///
/// It is a stateful widget because it manages some state of its own,
/// such as whether the game is in a "celebration" state.
class LevelScreen extends StatefulWidget {
  final GameLevel level;

  const LevelScreen(this.level, {super.key});

  @override
  State<LevelScreen> createState() => _LevelScreenState();
}

class _LevelScreenState extends State<LevelScreen> {
  static final _log = Logger('LevelScreen');

  static const _celebrationDuration = Duration(milliseconds: 2000);

  static const _preCelebrationDuration = Duration(milliseconds: 500);

  bool _duringCelebration = false;

  // ignore: unused_field
  late DateTime _startOfPlay;

  @override
  void initState() {
    super.initState();

    _startOfPlay = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();

    return MultiProvider(
      providers: [
        Provider.value(value: widget.level),
        // Create and provide the [LevelState] object that will be used
        // by widgets below this one in the widget tree.
        ChangeNotifierProvider(
          create: (context) => LevelState(
            goal: widget.level.difficulty,
            maxMoves: widget.level.maxMoves,
            onWin: _playerWon,
            onFail: _playerFailed,
          ),
        ),
      ],
      child: IgnorePointer(
        // Ignore all input during the celebration animation.
        ignoring: _duringCelebration,
        child: Scaffold(
          backgroundColor: palette.twilight,
          // The stack is how you layer widgets on top of each other.
          // Here, it is used to overlay the winning confetti animation on top
          // of the game.
          body: Stack(
            children: [
              // This is the main layout of the play session screen,
              // with a settings button on top, the actual play area
              // in the middle, and a back button at the bottom.
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: InkResponse(
                      onTap: () => GoRouter.of(context).push('/settings'),
                      child: Image.asset(
                        'assets/images/settings.png',
                        semanticLabel: 'Settings',
                      ),
                    ),
                  ),
                  const Spacer(),
                  const Expanded(
                    // The actual UI of the game.
                    child: GameWidget(),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CustomButton(
                      onPressed: () => GoRouter.of(context).go('/play'),
                      child: const Text('Back'),
                    ),
                  ),
                ],
              ),
              // This is the confetti animation that is overlaid on top of the
              // game when the player wins.
              SizedBox.expand(
                child: Visibility(
                  visible: _duringCelebration,
                  child: IgnorePointer(
                    child: Confetti(isStopped: !_duringCelebration),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _playerWon(int starsEarned) async {
    _log.info('Level ${widget.level.number} won with $starsEarned stars!');

    final levelDataController = context.read<LevelDataController>();

    await levelDataController.saveLevelCompletion(widget.level.number, starsEarned);

    await Future<void>.delayed(_preCelebrationDuration);
    if (!mounted) return;

    setState(() {
      _duringCelebration = true;
    });

    final audioController = context.read<AudioController>();
    audioController.playSfx(SfxType.congrats);

    await Future<void>.delayed(_celebrationDuration);
    if (!mounted) return;

    GoRouter.of(context).go(
      '/play/won',
      extra: {'level': widget.level.number, 'stars': starsEarned},
    );
  }

  void _playerFailed() {
    _log.info('Level ${widget.level.number} failed');

    context.read<AudioController>().playSfx(SfxType.fail);

    if (!mounted) return;

    GoRouter.of(context).go('/play/fail/${widget.level.number}');
  }
}
