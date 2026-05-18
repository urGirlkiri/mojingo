import 'package:flutter/material.dart';
import 'package:grimoji/features/audio/audio_controller.dart';
import 'package:grimoji/features/audio/sounds.dart';
import 'package:grimoji/config/levels.dart';
import 'package:grimoji/features/map/widgets/level_start_dialog.dart';
import 'package:grimoji/utils/responsive.dart';
import 'package:provider/provider.dart';

class LevelNode extends StatelessWidget {
  final GameLevel level;
  final int stars;

  const LevelNode({super.key, required this.level, required this.stars});

  @override
  Widget build(BuildContext context) {
    final isLarge = context.isLargeScreen;

    final double nodeSize = isLarge ? 85.0 : 45.0;
    final double fontSize = isLarge ? 28.0 : 16.0;

    var imagePath = "assets/images/map/level.png";

    switch (stars) {
      case 1:
        imagePath = "assets/images/map/level_1_star.png";
        break;
      case 2:
        imagePath = "assets/images/map/level_2_stars.png";
        break;
      case 3:
        imagePath = "assets/images/map/level_3_stars.png";
        break;
    }

    return InkWell(
      borderRadius: BorderRadius.circular(100),
      onTap: () => _showLevelDialog(context),
      child: SizedBox(
        width: 100,
        height: 100,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Image.asset(
              imagePath,
              fit: BoxFit.contain,
              width: nodeSize,
              height: nodeSize,
            ),
            Positioned(
              top: stars > 0 ? (isLarge ? 18 : 30) : null,
              child: Text(
                level.number.toString(),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLevelDialog(BuildContext context) {
    final audioController = context.read<AudioController>();
    audioController.playSfx(SfxType.buttonTap);

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: .7),
      builder: (BuildContext context) {
        return LevelStartDialog(level: level);
      },
    );
  }
}
