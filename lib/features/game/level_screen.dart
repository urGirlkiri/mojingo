import 'package:flutter/material.dart';
import 'package:mojingo/features/game/logic/levels.dart';
import 'package:mojingo/features/game/widgets/game_board.dart';
import 'package:mojingo/features/game/widgets/header.dart';
import 'package:mojingo/features/game/widgets/power_ups.dart';
import 'package:mojingo/features/map/widgets/level_quit_dialog.dart';
import 'package:mojingo/widgets/responsive_screen.dart';

class LevelScreen extends StatefulWidget {
  final GameLevel level;

  const LevelScreen({super.key, required this.level});

  @override
  State<LevelScreen> createState() => _LevelScreenState();
}

class _LevelScreenState extends State<LevelScreen> {
  bool _isQuitDialogOpen = false;

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

  @override
  Widget build(BuildContext context) {
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
      child: Scaffold(
        body: ResponsiveScreen(
          topMessageArea: Header(level: widget.level),
          squarishMainArea: GameBoard(),
          rectangularMenuArea: PowerUps(),
          mobileBackgroundImage: const AssetImage('assets/images/level/game.png'),
          desktopBackgroundImage: const AssetImage(
            'assets/images/level/large_game.png',
          ),
        ),
      ),
    );
  }
}
