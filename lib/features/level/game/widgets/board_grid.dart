import 'package:flutter/material.dart';
import 'package:grimoji/config/board.dart';
import 'package:grimoji/config/palette.dart';

class BoardGrid extends StatelessWidget {
  final int gridColumns;
  final int totalTiles;
  final double aspectRatio;
  final GlobalKey firstTileKey;
  final Palette palette;

  const BoardGrid({
    super.key,
    required this.gridColumns,
    required this.totalTiles,
    required this.aspectRatio,
    required this.firstTileKey,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: gridColumns,
        crossAxisSpacing: tileSpacingGap,
        mainAxisSpacing: tileSpacingGap,
        childAspectRatio: aspectRatio,
      ),
      itemCount: totalTiles,
      itemBuilder: (context, tileIndex) {
        return Container(
          key: tileIndex == 0 ? firstTileKey : null,
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
        );
      },
    );
  }
}