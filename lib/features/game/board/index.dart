import 'dart:async';
import 'package:flutter/material.dart';
import 'package:grimoji/config/constants.dart';
import 'package:grimoji/config/palette.dart';
import 'package:grimoji/features/game/board/models/sparkle_effect.dart';
import 'package:grimoji/features/game/board/widgets/announcer.dart';
import 'package:grimoji/features/game/board/widgets/board_grid.dart';
import 'package:grimoji/features/game/board/metrics.dart';
import 'package:grimoji/features/game/board/widgets/tile_grid.dart';
import 'package:grimoji/features/game/model/tile.dart';
import 'package:grimoji/features/game/model/coordinate.dart';
import 'package:grimoji/features/level/state.dart';
import 'package:lottie/lottie.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

class GameBoard extends StatefulWidget {
  const GameBoard({super.key});

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  final GlobalKey _boardKey = GlobalKey();
  final GlobalKey _tileKey = GlobalKey();
  final Logger _log = Logger('Game Board');

  Tile? _draggedTile;
  Offset? _dragStartPosition;
  
  final List<SparkleEffect> _sparkles = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _measureBoard();
    });
  }

  void _measureBoard() {
    if (!mounted) return;

    final boardContext = _boardKey.currentContext;
    final cellContext = _tileKey.currentContext;

    if (boardContext != null && cellContext != null) {
      final boardBox = boardContext.findRenderObject() as RenderBox;
      final cellBox = cellContext.findRenderObject() as RenderBox;
      final boardRect = boardBox.localToGlobal(Offset.zero) & boardBox.size;

      context.read<BoardMetrics>().updateMetrics(
        cellBox.size.width,
        cellBox.size.height,
        boardRect,
      );
    }
  }

  void _triggerSparkle(Offset localPosition) {
    final sparkle = SparkleEffect(position: localPosition);
    setState(() {
      _sparkles.add(sparkle);
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _sparkles.removeWhere((s) => s.id == sparkle.id);
        });
      }
    });
  }

  void _clearDrag() {
    if (_draggedTile != null || _dragStartPosition != null) {
      setState(() {
        _draggedTile = null;
        _dragStartPosition = null;
      });
    }
  }

  void onPanStart(DragStartDetails details, BuildContext contex,) {
    final metrics = context.read<BoardMetrics>();
    final levelstate = context.read<LevelState>();

    if (!metrics.isReady) return;

    if (levelstate.gameState.isProcessing || levelstate.gameState.isShuffling) {
      _triggerSparkle(details.localPosition);
      return;
    }

    int col = (details.localPosition.dx / metrics.tileWidth!).floor();
    int row = (details.localPosition.dy / metrics.tileHeight!).floor();

    if (row >= 0 &&
        row < levelstate.gameState.gameController.getRowCount() &&
        col >= 0 &&
        col < levelstate.gameState.gameController.getColCount()) {
      levelstate.gameState.resetTimer();
      setState(() {
        _draggedTile = levelstate.gameState.gameController.grid[row][col];
        _dragStartPosition = details.localPosition;
      });
    }
  }

  void onPanUpdate(DragUpdateDetails details, LevelState levelState) {
    if (_draggedTile == null || _dragStartPosition == null) return;

    final dx = details.localPosition.dx - _dragStartPosition!.dx;
    final dy = details.localPosition.dy - _dragStartPosition!.dy;
    final gameController = levelState.gameState.gameController;

    if (dx.abs() > 20 || dy.abs() > 20) {
      int targetRow = _draggedTile!.coordinate.row;
      int targetCol = _draggedTile!.coordinate.col;

      if (dx.abs() > dy.abs()) {
        targetCol += dx > 0 ? 1 : -1;
      } else {
        targetRow += dy > 0 ? 1 : -1;
      }

      if (targetRow >= 0 &&
          targetRow < gameController.getRowCount() &&
          targetCol >= 0 &&
          targetCol < gameController.getColCount()) {
        levelState.gameState.resolveSwipe(
          _draggedTile!.coordinate,
          TileCoordinate(row: targetRow, col: targetCol),
        );
      } else {
        _log.info('Swipe hit the boarder! Ignored.');
        _triggerSparkle(details.localPosition);
      }

      _clearDrag(); 
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();
    final levelstate = context.watch<LevelState>();
    final gameController = levelstate.gameState.gameController;

    final int gridColumns = gameController.getColCount();
    final int gridRows = gameController.getRowCount();

    const double maxAllowedBoardWidth = 350.0;
    final int totalTiles = gridColumns * gridRows;

    return LayoutBuilder(
      builder: (context, screenConstraints) {
        final double screenWidth = screenConstraints.maxWidth;
        final double screenHeight = screenConstraints.maxHeight;
        final bool isSmallScreen = screenWidth < 360 || screenHeight < 600;

        final double constrainedBoardWidth = isSmallScreen
            ? screenWidth * 0.95
            : (screenWidth > maxAllowedBoardWidth
                ? maxAllowedBoardWidth
                : screenWidth * 0.9);

        final double proportionalBoardHeight =
            (constrainedBoardWidth * gridRows) / gridColumns;

        return Center(
          child: SizedBox(
            width: constrainedBoardWidth,
            height: proportionalBoardHeight,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(isSmallScreen ? 6.0 : 8.0),
                  clipBehavior: Clip.hardEdge,
                  decoration: ShapeDecoration(
                    color: palette.mist,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: LayoutBuilder(
                    builder: (context, gridAreaConstraints) {
                      int horizontalGapsCount = gridColumns - 1;
                      int verticalGapsCount = gridRows - 1;

                      final double calculatedSingleTileWidth =
                          (gridAreaConstraints.maxWidth -
                              (tileSpacingGap * horizontalGapsCount)) /
                          gridColumns;
                      final double calculatedSingleTileHeight =
                          (gridAreaConstraints.maxHeight -
                              (tileSpacingGap * verticalGapsCount)) /
                          gridRows;

                      final double dynamicTileAspectRatio =
                          calculatedSingleTileWidth / calculatedSingleTileHeight;

                      return GestureDetector(
                        onPanStart: (details) => onPanStart(details, context),
                        onPanUpdate: (details) => onPanUpdate(details, levelstate),
                        onPanEnd: (details) => _clearDrag(), 
                        onPanCancel: () => _clearDrag(),     
                        child: Stack(
                          key: _boardKey,
                          clipBehavior: Clip.none,
                          children: [
                            BoardGrid(
                              gridColumns: gridColumns,
                              totalTiles: totalTiles,
                              aspectRatio: dynamicTileAspectRatio,
                              firstTileKey: _tileKey,
                              palette: palette,
                            ),
                            TileGrid(activeTileId: _draggedTile?.id),
                            
                            ..._sparkles.map((sparkle) {
                              return Positioned(
                                key: ValueKey(sparkle.id),
                                left: sparkle.position.dx - 50,
                                top: sparkle.position.dy - 50,
                                child: IgnorePointer( 
                                  child: SizedBox(
                                    width: 100,
                                    height: 100,
                                    child: Lottie.asset(
                                      'assets/lottie/stars.json',
                                      repeat: false,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                if (levelstate.gameState.activeAnnouncement != null)
                  AnnouncerWidget(
                    phrase: levelstate.gameState.activeAnnouncement!,
                    animationToken: levelstate.gameState.announcementToken,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
