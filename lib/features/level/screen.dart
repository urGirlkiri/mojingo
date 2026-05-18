import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:grimoji/config/levels/game_level.dart';
import 'package:grimoji/features/audio/audio_controller.dart';
import 'package:grimoji/features/audio/sounds.dart';
import 'package:grimoji/config/palette.dart';
import 'package:grimoji/config/routes.dart';
import 'package:grimoji/features/game/board/metrics.dart';
import 'package:grimoji/features/level/state.dart';
import 'package:grimoji/features/level/widgets/confetti.dart';
import 'package:grimoji/features/game/board/index.dart';
import 'package:grimoji/features/level/widgets/header.dart';
import 'package:grimoji/features/level/widgets/footer.dart';
import 'package:grimoji/features/level/controller.dart';
import 'package:grimoji/features/level/dialogs/quit_dialog.dart';
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
  bool _duringCelebration = false;
  bool _isQuitDialogOpen = false;

  static final _log = Logger('LevelScreen');
  static const _celebrationDuration = Duration(milliseconds: 2000);
  static const _preCelebrationDuration = Duration(milliseconds: 500);

  Palette get palette => Palette();

  void _showQuitDialog() {
    if (_isQuitDialogOpen) return;

    setState(() {
      _isQuitDialogOpen = true;
    });

    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: palette.voidBlack.withValues(alpha: 0.7),
      builder: (context) => QuitDialog(level: widget.level.number),
    ).then((_) {
      if (mounted) {
        setState(() {
          _isQuitDialogOpen = false;
        });
      }
    });
  }

  Future<void> _playerWon(int starsEarned) async {
    if (!mounted) return;
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

    GoRouter.of(context).goNamed(
      Routes.levelWon,
      extra: {'level': widget.level.number, 'stars': starsEarned},
    );
  }

  Future<void> _playerFailed() async {
    if (!mounted) return;
    _log.info('Level ${widget.level.number} failed');

    context.read<AudioController>().playSfx(SfxType.fail);

    if (!mounted) return;

    GoRouter.of(context).goNamed(
      Routes.levelFail,
      pathParameters: {'level': widget.level.number.toString()},
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider.value(value: widget.level),

        ChangeNotifierProvider(
          create: (_) => LevelState(
            onWin: _playerWon,
            onLose: _playerFailed,
            level: widget.level,
          ),
        ),
        ChangeNotifierProvider(create: (_) => BoardMetrics()),
      ],

      child: Builder(
        builder: (context) {
          return PopScope(
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
                      topMessageArea: Header(),
                      squarishMainArea: const GameBoard(),
                      rectangularMenuArea: Foooter(),
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
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
