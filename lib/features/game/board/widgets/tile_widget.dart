import 'package:flutter/material.dart';
import 'package:grimoji/config/constants.dart';
import 'package:grimoji/config/emojis.dart';
import 'package:grimoji/config/palette.dart';
import 'package:grimoji/features/alchemy/recipe_book.dart';
import 'package:grimoji/features/game/board/widgets/hit_nudge.dart';
import 'package:grimoji/features/game/model/tile.dart';
import 'package:grimoji/features/alchemy/reactions/reaction.dart';
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
    this.isTouched = false,
  });

  final Tile tile;
  final double leftPixel;
  final double topPixel;
  final double tWidth;
  final double tHeight;
  final GameEmoji? emoji;
  final bool isTouched;

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: swapAnimationTime,
      curve: Curves.easeOutCubic,
      left: leftPixel,
      top: topPixel,
      width: tWidth,
      height: tHeight,
      child: Center(child: _buildTileContent(context)),
    );
  }

  Widget _buildTileContent(BuildContext context) {
    if (tile.hasFlown) {
      return const SizedBox.shrink();
    }

    final palette = context.read<Palette>();

    final displayEmoji = tile.morphTarget ?? tile.emoji;

    Widget emojiUI = AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      transitionBuilder: (Widget child, Animation<double> animation) {
        if (tile.isTransmuting) {
          return RotationTransition(
            turns: Tween<double>(begin: -0.5, end: 0.0).animate(animation),
            child: FadeTransition(
              opacity: animation,
              child: ScaleTransition(scale: animation, child: child),
            ),
          );
        }
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

    final reaction = RecipeBook.getReactionFor(displayEmoji);
    final isExplosive =
        reaction != null && reaction.type == ReactionType.explosive;

    double targetScale = 1.0;
    double targetOpacity = 1.0;

    if (tile.isExploding) {
      targetScale = 0.0;
      if (isExplosive) targetOpacity = 0.0;
    } else if (tile.isMerging) {
      targetScale = 0.0;
    } else if (tile.isMergePoint) {
      targetScale = 1.3;
    } else if (tile.isTriggered) {
      targetScale = 1.1;
    } else if (isTouched) {
      targetScale = 1.15;
    }

    Widget scaledEmoji = AnimatedScale(
      scale: targetScale,
      duration: Duration(milliseconds: isTouched ? 100 : 200),
      curve: tile.isMergePoint ? Curves.elasticOut : Curves.easeOutBack,
      child: emojiUI,
    );

    Widget fadingEmoji = AnimatedOpacity(
      opacity: targetOpacity,
      duration: const Duration(milliseconds: 50),
      child: scaledEmoji,
    );

    if (tile.isTriggered) {
      fadingEmoji = Transform.rotate(
        angle:
            (DateTime.now().millisecondsSinceEpoch % 200).abs() / 100 * 0.1 -
            0.05,
        child: fadingEmoji,
      );
    }

    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        fadingEmoji,
        if (tile.isExploding)
          isExplosive
              ? OverflowBox(
                  maxWidth: tWidth * 30,
                  maxHeight: tHeight * 30,
                  child: Transform.translate(
                    offset: const Offset(1.0, 200.0),
                    child: Transform.rotate(
                      angle: 180,
                      child: Lottie.asset(
                        "assets/lottie/explosion.json",
                        width: tWidth * 10,
                        height: tHeight * 10,
                        fit: BoxFit.cover,
                        animate: true,
                        repeat: false,
                      ),
                    ),
                  ),
                )
              : OverflowBox(
                  maxWidth: tWidth * 1.2,
                  maxHeight: tHeight * 1.2,
                  child: Transform.translate(
                    offset: const Offset(-25.0, 0.0),
                    child: Lottie.asset(
                      "assets/lottie/puff.json",
                      width: tWidth * 1.2,
                      height: tHeight * 1.2,
                      fit: BoxFit.cover,
                      animate: true,
                      repeat: false,
                      delegates: LottieDelegates(
                        values: [
                          ValueDelegate.colorFilter(
                            ['**'],
                            value: ColorFilter.mode(
                              palette.trueWhite,
                              BlendMode.srcATop,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
      ],
    );
  }
}
