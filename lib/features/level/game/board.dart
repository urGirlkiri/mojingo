import 'package:flutter/material.dart';
import 'package:grimoji/config/constants.dart';
import 'package:grimoji/config/palette.dart';
import 'package:grimoji/features/level/game/widgets/board_grid.dart';
import 'package:grimoji/features/level/game/metrics.dart';
import 'package:grimoji/features/level/game/widgets/tile_grid.dart';
import 'package:grimoji/features/level/game/model/tile.dart';
import 'package:grimoji/features/level/game/model/coordinate.dart'; // Added for TileCoordinate
import 'package:grimoji/features/level/state.dart';
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

  void onPanStart(DragStartDetails details, BuildContext context) {
    _log.info('Touch Detected');
    final metrics = context.read<BoardMetrics>();
    final gameController = context.read<LevelState>().gameState.gameController;

    if (!metrics.isReady) return;

    int col = (details.localPosition.dx / metrics.tileWidth!).floor();
    int row = (details.localPosition.dy / metrics.tileHeight!).floor();

    _log.info('Touch Coordinates -> row: $row, col: $col');

    if (row >= 0 &&
        row < gameController.getRowCount() &&
        col >= 0 &&
        col < gameController.getColCount()) {
      _draggedTile = gameController.grid[row][col];
      _dragStartPosition = details.localPosition;
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
        _log.info(dx > 0 ? 'Swiped RIGHT' : 'Swiped LEFT');
      } else {
        targetRow += dy > 0 ? 1 : -1;
        _log.info(dy > 0 ? 'Swiped DOWN' : 'Swiped UP');
      }

      if (targetRow >= 0 &&
          targetRow < gameController.getRowCount() &&
          targetCol >= 0 &&
          targetCol < gameController.getColCount()) {
          
      _log.info('Target valid. Initiating match sequence...');
      levelState.gameState.resolveSwipe(
          _draggedTile!.coordinate,
          TileCoordinate(row: targetRow, col: targetCol),
        );
      } else {
        _log.info('Swipe hit the boarder! Ignored.');
      }

      _draggedTile = null;
      _dragStartPosition = null;
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
        final double constrainedBoardWidth =
            screenConstraints.maxWidth > maxAllowedBoardWidth
            ? maxAllowedBoardWidth
            : screenConstraints.maxWidth;

        final double proportionalBoardHeight =
            (constrainedBoardWidth * gridRows) / gridColumns;

        return Center(
          child: SizedBox(
            width: constrainedBoardWidth,
            height: proportionalBoardHeight,
            child: Container(
              padding: const EdgeInsets.all(8.0),
              clipBehavior: Clip.hardEdge,
              decoration: ShapeDecoration(
                color: palette.mist,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
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
                    onPanStart: (details) => levelstate.gameState.isProcessing ? null : onPanStart(details, context),
                    onPanUpdate: (details) => onPanUpdate(details, levelstate),
                    child: Stack(
                      key: _boardKey,
                      children: [
                        BoardGrid(
                          gridColumns: gridColumns,
                          totalTiles: totalTiles,
                          aspectRatio: dynamicTileAspectRatio,
                          firstTileKey: _tileKey,
                          palette: palette,
                        ),
                        TileGrid(),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
