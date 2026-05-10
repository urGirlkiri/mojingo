import 'package:flutter/material.dart';
import 'package:grimoji/config/board.dart';
import 'package:grimoji/features/level/game/metrics.dart';
import 'package:grimoji/features/level/state.dart';
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
      if (levelState.gameController.grid[0][0].coordinate.row < 0) {
        levelState.startInitialDrop();
      }
    });
    final double tWidth = metrics.tileWidth!;
    final double tHeight = metrics.tileHeight!;

    List<Widget> tileWidgets = [];

    int nRow = levelState.gameController.getRowCount();
    int nCol = levelState.gameController.getColCount();

    for (int r = 0; r < nRow; r++) {
      for (int c = 0; c < nCol; c++) {
        final tile = levelState.gameController.grid[r][c];

        final double leftPixel = (tile.coordinate.col * tWidth) + (tile.coordinate.col * tileSpacingGap);
        final double topPixel = (tile.coordinate.row * tHeight) + (tile.coordinate.row * tileSpacingGap);

        tileWidgets.add(
          AnimatedPositioned(
            key: ValueKey(tile.id),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            left: leftPixel,
            top: topPixel,
            width: tWidth,
            height: tHeight,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Center(
                child: EmojiWidget.svg(
                  path: tile.emoji.svg,
                  size: tWidth * 0.8,
                ),
              ),
            ),
          ),
        );
      }
    }

    return Stack(children: tileWidgets);
  }
}
