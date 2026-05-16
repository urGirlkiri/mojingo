import 'dart:math';

import 'package:flutter/material.dart';
import 'package:grimoji/config/constants.dart';
import 'package:grimoji/config/palette.dart';
import 'package:grimoji/features/game/board/metrics.dart';
import 'package:grimoji/animations/flight.dart';
import 'package:grimoji/features/game/board/widgets/tile_widget.dart';
import 'package:grimoji/features/level/state.dart';
import 'package:grimoji/features/game/model/tile.dart';
import 'package:provider/provider.dart';

class TileGrid extends StatelessWidget {
  static const shuffleDuration = Duration(milliseconds: 600);

  const TileGrid({super.key});

  void _initialFall(BuildContext context, LevelState levelState) {
    if (levelState.gameState.gameController.grid[0][0].coordinate.row < 0) {
      Future.microtask(() {
        if (!context.mounted) return;
        levelState.gameState.startInitialDrop();
        levelState.startLevel();
      });
    }
  }

  void _launchTargetEmo(
    BuildContext context,
    Tile tile,
    LevelState levelState,
    double leftPixel,
    double topPixel,
  ) {
    tile.hasFlown = true;

    final targetKey = levelState.targetIconKey;

    Future.microtask(() {
      if (!context.mounted) return;

      final RenderBox? boardBox = context.findRenderObject() as RenderBox?;
      if (boardBox == null) return;

      final Offset globalStart = boardBox.localToGlobal(
        Offset(leftPixel, topPixel),
      );

      final int randomDelay = Random().nextInt(200);

      Future.delayed(Duration(milliseconds: randomDelay), () {
        if (!context.mounted) return;
        if (targetKey.currentContext == null) return;
        TargetFlightAnimator.launch(
          context: context,
          startOffset: globalStart,
          targetKey: targetKey,
          emoji: tile.emoji,
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final metrics = context.watch<BoardMetrics>();
    final levelState = context.watch<LevelState>();

    if (!metrics.isReady) {
      return const SizedBox.shrink();
    }

    _initialFall(context, levelState);

    final double tWidth = metrics.tileWidth!;
    final double tHeight = metrics.tileHeight!;
    final grid = levelState.gameState.gameController.grid;

    List<Widget> tileWidgets = [];
    int nRol = grid.length;
    int nCol = grid[0].length;

    for (int r = 0; r < nRol; r++) {
      for (int c = 0; c < nCol; c++) {
        final tile = grid[r][c];

        final double leftPixel =
            (tile.coordinate.col * tWidth) +
            (tile.coordinate.col * tileSpacingGap);
        final double topPixel =
            (tile.coordinate.row * tHeight) +
            (tile.coordinate.row * tileSpacingGap);

        bool isTargetMatch = (tile.emoji == levelState.level.targetEmoji);
        bool shouldFly = tile.isFlying && !tile.hasFlown && isTargetMatch;

        shouldFly
            ? _launchTargetEmo(context, tile, levelState, leftPixel, topPixel)
            : null;

        tileWidgets.add(
          TileWidget(
            tile: tile,
            leftPixel: leftPixel,
            topPixel: topPixel,
            tWidth: tWidth,
            tHeight: tHeight,
            emoji: tile.emoji,
          ),
        );
      }
    }
    final double boardWidth = (nCol * tWidth) + ((nCol - 1) * tileSpacingGap);

    final double targetWidth = levelState.gameState.shuffleProgress;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 1.0, end: targetWidth),
      duration: shuffleDuration,
      curve: Curves.easeInOutCubic,
      builder: (context, widthFactor, child) {
        final double edgeX = boardWidth * widthFactor;

        return Stack(
          children: [
            ClipRect(
              child: Align(
                alignment: Alignment.centerLeft,
                widthFactor: widthFactor,
                child: SizedBox(
                  width: boardWidth,
                  child: Stack(children: tileWidgets),
                ),
              ),
            ),

            if (widthFactor > 0.0 && widthFactor < 1.0)
              _buildShuffleIndicator(edgeX, context),
          ],
        );
      },
    );
  }

  Widget _buildShuffleIndicator(double edgeX, BuildContext context) {
    final palette = context.read<Palette>();
    return Positioned(
      left: edgeX - 25,
      top: 0,
      bottom: 0,
      width: 30,
      child: Container(
        decoration: BoxDecoration(
          color: palette.trueWhite,
          gradient: LinearGradient(
            colors: [palette.voidBlack, palette.trueWhite, palette.midnight],
            stops: [0.0, 0.5, 1.0],
          ),
          boxShadow: [
            BoxShadow(
              color: palette.voidBlack.withValues(alpha: .5),
              blurRadius: 12,
              spreadRadius: 2,
              offset: const Offset(-8, 0),
            ),
          ],
        ),
      ),
    );
  }
}
