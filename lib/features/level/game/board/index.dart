import 'package:flutter/material.dart';
import 'package:grimoji/config/board.dart';
import 'package:grimoji/config/palette.dart';
import 'package:grimoji/features/level/game/board/metrics.dart';
import 'package:grimoji/features/level/game/board/tile_grid.dart';
import 'package:grimoji/features/level/state.dart';
import 'package:provider/provider.dart';

class GameBoard extends StatefulWidget {
  const GameBoard({super.key});

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  final GlobalKey _boardKey = GlobalKey();
  final GlobalKey _tileKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _measureBoard();
    });
  }

  void _measureBoard() {
    if (!mounted) return;

    final boardcontex = _boardKey.currentContext;
    final cellContext = _tileKey.currentContext;

    if (boardcontex != null && cellContext != null) {
      final boardBox = boardcontex.findRenderObject() as RenderBox;
      final cellBox = cellContext.findRenderObject() as RenderBox;

      final boardRect = boardBox.localToGlobal(Offset.zero) & boardBox.size;

      context.read<BoardMetrics>().updateMetrics(
        cellBox.size.width,
        cellBox.size.height,
        boardRect,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();

    final levelstate = context.watch<LevelState>();
    final gameController = levelstate.gameController;

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

                  return Stack(
                    key: _boardKey,
                    children: [
                      GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: gridColumns,
                          crossAxisSpacing: tileSpacingGap,
                          mainAxisSpacing: tileSpacingGap,
                          childAspectRatio: dynamicTileAspectRatio,
                        ),
                        itemCount: totalTiles,
                        itemBuilder: (context, tileIndex) {
                          return Container(
                            key: tileIndex == 0 ? _tileKey : null,
                            decoration: BoxDecoration(
                              color: palette.twilight.withValues(alpha: 0.38),
                              border: Border.all(color: palette.dusk, width: 1),
                              borderRadius: BorderRadius.circular(4),
                              boxShadow: [
                                BoxShadow(
                                  color: palette.voidBlack.withValues(
                                    alpha: 0.4,
                                  ),
                                  blurRadius: 4,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      const TileGrid(),
                    ],
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
