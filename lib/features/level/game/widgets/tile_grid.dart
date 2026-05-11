import 'dart:math';

import 'package:flutter/material.dart';
import 'package:grimoji/config/constants.dart';
import 'package:grimoji/config/emojis.dart';
import 'package:grimoji/config/palette.dart';
import 'package:grimoji/features/level/game/metrics.dart';
import 'package:grimoji/features/level/game/widgets/flight_animation.dart';
import 'package:grimoji/features/level/game/widgets/hit_nudge.dart';
import 'package:grimoji/features/level/state.dart';
import 'package:grimoji/features/level/game/model/tile.dart';
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

        _launchTargetEmo(context, tile, levelState, leftPixel, topPixel);

        tileWidgets.add(
          _buildAnimatedTile(
            context,
            tile,
            leftPixel,
            topPixel,
            tWidth,
            tHeight,
            tile.emoji,
          ),
        );
      }
    }
    final double boardWidth = (nCol * tWidth) + ((nCol - 1) * tileSpacingGap);

    final double targetWidth = levelState.gameState.shuffleProgress;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 1.0, end: targetWidth),
      duration: const Duration(milliseconds: 600),
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
            colors: [
              palette.voidBlack,
              palette.trueWhite,
              palette.midnight,
            ],
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
    bool isTargetMatch = (tile.emoji == levelState.level.targetEmoji);

    bool shouldFly = tile.isFlying && !tile.hasFlown && isTargetMatch;

    if (shouldFly) {
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
  }

  Widget _buildTileContent(
    BuildContext context,
    Tile tile,
    double tWidth,
    double tHeight,
    GameEmoji? emoji,
  ) {
    if (tile.hasFlown) {
      return const SizedBox.shrink();
    }

    final palette = context.read<Palette>();

    if (tile.isExploding) {
      return Lottie.asset(
        "assets/lottie/puff.json",
        width: tWidth * 500,
        height: tHeight * 500,
        fit: BoxFit.cover,
        animate: true,
        frameRate: const FrameRate(60),
        delegates: LottieDelegates(
          values: [
            ValueDelegate.colorFilter([
              '**',
            ], value: ColorFilter.mode(palette.trueWhite, BlendMode.srcATop)),
          ],
        ),
      );
    } else if (tile.isMerging && emoji != null) {
      return Lottie.asset(
        emoji.lottie,
        width: tWidth,
        height: tHeight,
        fit: BoxFit.fill,
        animate: true,
        frameRate: const FrameRate(60),
      );
    } else {
      Widget emojiUI = EmojiWidget.svg(
        path: tile.emoji.svg,
        size: tWidth * 0.8,
      );

      return HintNudge(
        isHinting: tile.isHinting,
        current: tile.coordinate,
        partner: tile.hintPartner,
        tileWidth: tWidth,
        tileHeight: tHeight,
        child: emojiUI,
      );
    }
  }

  Widget _buildAnimatedTile(
    BuildContext context,
    Tile tile,
    double leftPixel,
    double topPixel,
    double tWidth,
    double tHeight,
    GameEmoji? emoji,
  ) {
    return AnimatedPositioned(
      key: ValueKey(tile.id),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
      left: leftPixel + (tile.isExploding || tile.isMerging ? -20 : 0),
      top: topPixel,
      width: tWidth,
      height: tHeight,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Center(child: _buildTileContent(context, tile, tWidth, tHeight, emoji)),
      ),
    );
  }
} 
