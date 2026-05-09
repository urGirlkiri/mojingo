import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../config/palette.dart';
import '../logic/levels.dart';

class WinGameScreen extends StatefulWidget {
  final int level;
  final int stars;

  const WinGameScreen({super.key, required this.level, required this.stars});

  @override
  State<WinGameScreen> createState() => _WinGameScreenState();
}

class _WinGameScreenState extends State<WinGameScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        final nextLevelNumber = widget.level + 1;
        final hasNextLevel = gameLevels.any(
          (level) => level.number == nextLevelNumber,
        );

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
      body: Center(
        child:  Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            gap,
            const Center(child: Text('You won!')),
            gap,
            Center(
              child: Text('${widget.stars} ⭐️'),
            ), 
          ],
        ),
      ),
    );
  }
}
