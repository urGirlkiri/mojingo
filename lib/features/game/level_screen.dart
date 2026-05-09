import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:grimoji/config/audio/audio_controller.dart';
import 'package:grimoji/config/audio/sounds.dart';
import 'package:grimoji/features/game/logic/level_state.dart';
import 'package:grimoji/features/game/logic/levels.dart';
import 'package:grimoji/features/game/widgets/confetti.dart';
import 'package:grimoji/features/game/widgets/game_board.dart';
import 'package:grimoji/features/game/widgets/header.dart';
import 'package:grimoji/features/game/widgets/power_ups.dart';
import 'package:grimoji/features/map/level_data_controller.dart';
import 'package:grimoji/features/map/widgets/level_quit_dialog.dart';
import 'package:grimoji/widgets/responsive_screen.dart';
import 'package:provider/provider.dart';
import 'package:logging/logging.dart' hide Level;

class LevelScreen extends StatefulWidget {
  final GameLevel level;

  const LevelScreen({super.key, required this.level});

  @override
  State<LevelScreen> createState() => _LevelScreenState();
}

class _LevelScreenState extends State<LevelScreen> {
  static final _log = Logger('LevelScreen');

  static const _celebrationDuration = Duration(milliseconds: 2000);
  static const _preCelebrationDuration = Duration(milliseconds: 500);

  bool _duringCelebration = false;
  bool _isQuitDialogOpen = false;

  // ignore: unused_field
  late DateTime _startOfPlay;

  void _showQuitDialog() {
    if (_isQuitDialogOpen) return;

    setState(() {
      _isQuitDialogOpen = true;
    });

    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      builder: (context) => LevelQuitDialog(level: widget.level.number),
    ).then((_) {
      if (mounted) {
        setState(() {
          _isQuitDialogOpen = false;
        });
      }
    });
  }

  Future<void> _playerWon(int starsEarned) async {
    _log.info('Level ${widget.level.number} won with $starsEarned stars!');

    final levelDataController = context.read<LevelDataController>();

    await levelDataController.saveLevelCompletion(
      widget.level.number,
      starsEarned,
    );

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

  Future<void> _playerFailed() async {
    _log.info('Level ${widget.level.number} failed');

    context.read<AudioController>().playSfx(SfxType.fail);

    if (!mounted) return;

    GoRouter.of(context).go('/play/fail/${widget.level.number}');
  }

  @override
  void initState() {
    super.initState();

    _startOfPlay = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider.value(value: widget.level),
        ChangeNotifierProvider(
          create: (context) => LevelState(
            goal: widget.level.difficulty,
            maxMoves: widget.level.maxMoves,
            onWin: _playerWon,
            onFail: _playerFailed,
          ),
        ),
      ],
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
      
          if (_isQuitDialogOpen) {
            Navigator.of(context).pop();
          } else {
            _showQuitDialog();
          }
        },
        child: IgnorePointer(
          ignoring: _duringCelebration,
      
          child: Scaffold(
            body: Stack(
              children: [
                ResponsiveScreen(
                topMessageArea: Header(level: widget.level),
                squarishMainArea: const GameBoard(),
                rectangularMenuArea: const PowerUps(),
                mobileBackgroundImage: const AssetImage(
                  'assets/images/level/game.png',
                ),
                desktopBackgroundImage: const AssetImage(
                  'assets/images/level/large_game.png',
                ),
              ),
              SizedBox.expand(
                  child: Visibility(
                    visible: _duringCelebration,
                    child: IgnorePointer(
                      child: Confetti(isStopped: !_duringCelebration),
                    ),
                  ),
                ),
              ]
            ),
          ),
        ),
      ),
    );
  }
}
