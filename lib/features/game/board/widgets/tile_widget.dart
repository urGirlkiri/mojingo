import 'package:flutter/material.dart';
import 'package:grimoji/config/constants.dart';
import 'package:grimoji/config/emojis.dart';
import 'package:grimoji/config/palette.dart';
import 'package:grimoji/features/game/board/widgets/hit_nudge.dart';
import 'package:grimoji/features/game/model/tile.dart';
import 'package:grimoji/widgets/emoji_widget.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class TileWidget extends StatelessWidget {
  const TileWidget({
    super.key,
    required this.tile,
    required this.leftPixel,
    required this.topPixel,
    required this.tWidth,
    required this.tHeight,
    required this.emoji,
  });

  final Tile tile;
  final double leftPixel;
  final double topPixel;
  final double tWidth;
  final double tHeight;
  final GameEmoji? emoji;

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: swapAnimationTime,
      curve: Curves.easeOutCubic,
      left: leftPixel,
      top: topPixel,
      width: tWidth,
      height: tHeight,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Center(child: _buildTileContent(context)),
      ),
    );
  }

  Widget _buildTileContent(BuildContext context) {
    if (tile.hasFlown) {
      return const SizedBox.shrink();
    }

    final palette = context.read<Palette>();
    
    final displayEmoji = tile.morphTarget ?? tile.emoji;

    Widget emojiUI = AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(scale: animation, child: child),
        );
      },
      child: EmojiWidget.svg(
        key: ValueKey(displayEmoji.visual), 
        path: displayEmoji.svg,
        size: tWidth * 0.8,
      ),
    );

    emojiUI = HintNudge(
      isHinting: tile.isHinting,
      current: tile.coordinate,
      partner: tile.hintPartner,
      tileWidth: tWidth,
      tileHeight: tHeight,
      child: emojiUI,
    );

    double targetScale = 1.0;
    if (tile.isExploding || tile.isMerging) {
      targetScale = 0.0; 
    } else if (tile.isMergePoint) {
      targetScale = 1.3; 
    }

    Widget scaledEmoji = AnimatedScale(
      scale: targetScale,
      duration: const Duration(milliseconds: 200),
      curve: tile.isMergePoint ? Curves.elasticOut : Curves.easeInBack,
      child: emojiUI,
    );

    if (!tile.isExploding && !tile.isMergePoint) {
      return scaledEmoji;
    }

    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        scaledEmoji,
        
        if (tile.isExploding)
          Lottie.asset(
            "assets/lottie/puff.json",
            width: tWidth * 1.5,
            height: tHeight * 1.5,
            fit: BoxFit.cover,
            animate: true,
            repeat: false, 
            delegates: LottieDelegates(
              values: [
                ValueDelegate.colorFilter([
                  '**',
                ], value: ColorFilter.mode(palette.trueWhite, BlendMode.srcATop)),
              ],
            ),
          ),
      ],
    );
  }
}