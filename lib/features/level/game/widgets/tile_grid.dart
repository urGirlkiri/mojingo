import 'package:flutter/material.dart';
import 'package:grimoji/config/board.dart';
import 'package:grimoji/features/level/game/metrics.dart';
import 'package:grimoji/features/level/state.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:grimoji/widgets/emoji_widget.dart';

class TileGrid extends StatelessWidget {
  const TileGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final metrics = context.watch<BoardMetrics>();
    final levelState = context.watch<LevelState>();

    if (!metrics.isReady) {
      return const SizedBox.shrink();
    }

    Future.microtask(() {
      if (levelState.gameState.gameController.grid[0][0].coordinate.row < 0) {
        levelState.gameState.startInitialDrop();
        levelState.startLevel();
      }
    });
    final double tWidth = metrics.tileWidth!;
    final double tHeight = metrics.tileHeight!;

    List<Widget> tileWidgets = [];

    int nRow = levelState.gameState.gameController.getRowCount();
    int nCol = levelState.gameState.gameController.getColCount();

    for (int r = 0; r < nRow; r++) {
      for (int c = 0; c < nCol; c++) {
        final tile = levelState.gameState.gameController.grid[r][c];

        final double leftPixel =
            (tile.coordinate.col * tWidth) +
            (tile.coordinate.col * tileSpacingGap);
        final double topPixel =
            (tile.coordinate.row * tHeight) +
            (tile.coordinate.row * tileSpacingGap);

        Widget tileContent;

        if (tile.isExploding) {
          tileContent = Lottie.asset(
            "assets/lottie/stars.json",
            width: tWidth *500,
            height: tHeight *500,
            fit: BoxFit.cover,
            animate: true,
            frameRate: FrameRate(60),
          );
        }
         else if (tile.isMerging) {
          tileContent = Lottie.asset(
            "assets/lottie/puff.json",
            width: tWidth *500,
            height: tHeight *500,
            fit: BoxFit.cover,
            animate: true,
            frameRate: FrameRate(60),
          );
        } 
        else {
          tileContent = EmojiWidget.svg(
            path: tile.emoji.svg,
            size: tWidth * 0.8,
          );
        }

        tileWidgets.add(
          AnimatedPositioned(
            key: ValueKey(tile.id),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            left: leftPixel + (tile.isExploding || tile.isMerging ? -20 : 0),
            top: topPixel ,
            width: tWidth,
            height: tHeight,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Center(child: tileContent),
            ),
          ),
        );
      }
    }

    return Stack(children: tileWidgets);
  }
}
