import 'package:flutter/material.dart';
import 'package:grimoji/config/palette.dart';
import 'package:grimoji/config/emojis.dart';
import 'package:grimoji/widgets/emoji_widget.dart'; 

class PowerUps extends StatelessWidget {
  const PowerUps({super.key});

  Palette get palette => Palette();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: ShapeDecoration(
        color: palette.mist,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildPowerUpBtn("assets/icons/app/pause.png", isSmall: true),
            const SizedBox(width: 12),
            _buildPowerUpBtn(Emojis.crystalBall.svg),
            const SizedBox(width: 12),
            _buildPowerUpBtn(Emojis.testTube.svg),
            const SizedBox(width: 12),
            _buildPowerUpBtn(Emojis.flyingDisc.svg),
            const SizedBox(width: 12),
            _buildPowerUpBtn(Emojis.comet.svg),
          ],
        ),
      ),
    );
  }

  Widget _buildPowerUpBtn(String assetPath, {bool isSmall = false}) {
    double size = isSmall ? 60 : 70;
    double iconSize = isSmall ? 60 : 50;
    
    return Container(
      width: size,
      height: size,
      decoration: ShapeDecoration(
        color: palette.mist,
        shape: CircleBorder(
          side: BorderSide(width: 3, color: palette.dusk),
        ),
        shadows:  [
          BoxShadow(
            color: palette.midnight, 
            blurRadius: 4,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Center(
        child: assetPath.endsWith('.svg')
            ? EmojiWidget.svg(
                path: assetPath,
                size: iconSize,
              )
            : Image.asset(
                assetPath,
                width: iconSize,
                height: iconSize,
              ),
      ),
    );
  }
}