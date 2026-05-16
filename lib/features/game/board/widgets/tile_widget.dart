import 'package:flutter/material.dart';
import 'package:grimoji/config/emojis.dart';
import 'package:grimoji/config/palette.dart';
import 'package:grimoji/features/game/board/widgets/hit_nudge.dart';
import 'package:grimoji/features/game/model/tile.dart';
import 'package:grimoji/widgets/emoji_widget.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class TileWidget extends StatelessWidget {
  static const movementDuration = Duration(milliseconds: 800);

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
      key: ValueKey(tile.id),
      duration: movementDuration,
      curve: Curves.easeOutCubic,
      left: leftPixel + (tile.isExploding || tile.isMerging ? -20 : 0),
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

    Widget emojiUI = EmojiWidget.svg(
      path: tile.emoji.svg,
      size: tWidth * 0.8,
    );

    emojiUI = HintNudge(
      isHinting: tile.isHinting,
      current: tile.coordinate,
      partner: tile.hintPartner,
      tileWidth: tWidth,
      tileHeight: tHeight,
      child: emojiUI,
    );

    double targetScale = 1;

    if (tile.isExploding) {
      targetScale = 0.0;
    } else if (tile.isMerging) {
      targetScale = 0.0;
    } else if (tile.isMergePoint) {
      targetScale = 1.3;
    }

    Widget scaledEmoji = AnimatedScale(
      scale: targetScale,
      duration: const Duration(milliseconds: 300),
      curve: tile.isMerging ? Curves.elasticOut : Curves.easeInBack,
      child: emojiUI,
    );

    if (!tile.isExploding && !tile.isMerging) {
      return scaledEmoji;
    }

    return Stack(
      alignment: Alignment.center,
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

        if (tile.isMerging && emoji != null)
          Lottie.asset(
            emoji!.lottie,
            width: tWidth * 1.2,
            height: tHeight * 1.2,
            fit: BoxFit.contain,
            animate: true,
            repeat: false, 
          ),
      ],
    );
  }
}
