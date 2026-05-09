import 'package:flutter/material.dart';
import 'package:grimoji/config/emojis.dart';
import 'package:grimoji/config/palette.dart';
import 'package:grimoji/widgets/emoji_widget.dart';
import 'package:provider/provider.dart';

class GameBoard extends StatelessWidget {
  const GameBoard({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();

    const double maxAllowedBoardWidth = 350.0;
    const int gridColumns = 5;
    const int gridRows = 8;
    const int totalTiles = gridColumns * gridRows;

    return LayoutBuilder(
      builder: (context, screenConstraints) {
        final double constrainedBoardWidth = screenConstraints.maxWidth > maxAllowedBoardWidth
            ? maxAllowedBoardWidth
            : screenConstraints.maxWidth;

        final double proportionalBoardHeight =
            (constrainedBoardWidth * gridRows) / gridColumns;

        return Center(
          child: SizedBox(
            width: constrainedBoardWidth,
            height: proportionalBoardHeight,
            child: Container(
              padding: const EdgeInsets.all(8.0), // Outer board padding
              decoration: ShapeDecoration(
                color: palette.mist,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: LayoutBuilder(
                builder: (context, gridAreaConstraints) {
                  const double tileSpacingGap = 2.0;

                  const int horizontalGapsCount = gridColumns - 1; 
                  const int verticalGapsCount = gridRows - 1;     

                  final double calculatedSingleTileWidth =
                      (gridAreaConstraints.maxWidth - (tileSpacingGap * horizontalGapsCount)) / gridColumns;
                  final double calculatedSingleTileHeight =
                      (gridAreaConstraints.maxHeight - (tileSpacingGap * verticalGapsCount)) / gridRows;

                  final double dynamicTileAspectRatio =
                      calculatedSingleTileWidth / calculatedSingleTileHeight;

                  return GridView.builder(
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
                        decoration: BoxDecoration(
                          color: palette.twilight.withValues(alpha: 0.38),
                          border: Border.all(color: palette.dusk, width: 1),
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: [
                            BoxShadow(
                              color: palette.voidBlack.withValues(alpha: 0.4),
                              blurRadius: 4,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: EmojiWidget(
                            assetPath: Emojis.plant.svg, 
                            size: 48,
                          ),
                        ),
                      );
                    },
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