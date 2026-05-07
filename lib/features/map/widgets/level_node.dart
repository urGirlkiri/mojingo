import 'package:flutter/material.dart';
import 'package:mojingo/config/audio/audio_controller.dart';
import 'package:mojingo/config/audio/sounds.dart';
import 'package:mojingo/features/map/widgets/level_start_dialog.dart';
import 'package:mojingo/utils/responsive.dart';
import 'package:provider/provider.dart';

class LevelNode extends StatelessWidget {
  final int level;

  const LevelNode({
    super.key,
    required this.level,
  });

  @override
  Widget build(BuildContext context) {
    final isLarge = context.isLargeScreen;

    final double nodeSize = isLarge ? 85.0 : 45.0;
    final double fontSize = isLarge ? 28.0 : 16.0;

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
              "assets/images/map/level.png",
              fit: BoxFit.contain,
              width: nodeSize,
              height: nodeSize,
            ),
            Text(
              "$level",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    shadows: const [
                      Shadow(
                        blurRadius: 8,
                        color: Colors.black54,
                        offset: Offset(0, 2),
                      ),
                    ],
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
        return LevelStartDialog(
          level: level, 
          targetEmoji: "☁️", 
        );
      },
    );
  }

}