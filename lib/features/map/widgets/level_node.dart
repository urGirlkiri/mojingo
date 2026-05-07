import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mojingo/config/audio/audio_controller.dart';
import 'package:mojingo/config/audio/sounds.dart';
import 'package:provider/provider.dart';

class LevelNode extends StatelessWidget {
  final int level;

  const LevelNode({super.key, required this.level});

  @override
  Widget build(BuildContext context) {

    return InkWell(
      onTap: () => _showLevelDialog(context),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(
            "assets/images/map/level.png",
            fit: BoxFit.fitWidth,
            width: 45,
          ),
          Text("$level", style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }

  void _showLevelDialog(BuildContext context) {
    final audioController = context.read<AudioController>();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Level $level"),
          content: const Text("Ready to play this level?"),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            FilledButton(
              child: const Text("Play"),
              onPressed: () {
                audioController.playSfx(SfxType.buttonTap);

                GoRouter.of(context).go('/play/session/$level');
              },
            ),
          ],
        );
      },
    );
  }
}
