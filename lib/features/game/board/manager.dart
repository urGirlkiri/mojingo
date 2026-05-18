import 'dart:math';
import 'package:grimoji/config/levels/game_level.dart';
import 'package:grimoji/config/emojis.dart';
import 'package:grimoji/features/game/model/tile.dart';
import 'package:grimoji/features/game/model/coordinate.dart';
import 'package:grimoji/features/alchemy/recipe_book.dart';
import 'package:grimoji/features/alchemy/reactions/reaction.dart';

class GridManager {
  static const int rows = 8;
  static const int cols = 5;

  late List<List<Tile>> gridTiles;
  final GameLevel level;
  final Random _random = Random();

  GridManager(this.level);

  void initialize() {
    gridTiles = List.generate(
      rows,
      (r) => List.generate(
        cols,
        (c) => Tile(
          coordinate: TileCoordinate(row: r - rows, col: c),
          emoji: level.availableEmojis[0],
        ),
      ),
    );

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        gridTiles[r][c].emoji = _getRandomSafeEmoji(r, c);
      }
    }
  }

  GameEmoji _getRandomSafeEmoji(int row, int col) {
    GameEmoji candidate = level.availableEmojis[0];
    bool isSafe = false;

    while (!isSafe) {
      candidate =
          level.availableEmojis[_random.nextInt(level.availableEmojis.length)];
      isSafe = true;

      if (col > 1 &&
          gridTiles[row][col - 1].emoji == candidate &&
          gridTiles[row][col - 2].emoji == candidate) {
        isSafe = false;
      }
      if (row > 1 &&
          gridTiles[row - 1][col].emoji == candidate &&
          gridTiles[row - 2][col].emoji == candidate) {
        isSafe = false;
      }
    }
    return candidate;
  }

  void swapTiles(TileCoordinate aCoord, TileCoordinate bCoord) {
    Tile tileA = gridTiles[aCoord.row][aCoord.col];
    Tile tileB = gridTiles[bCoord.row][bCoord.col];

    gridTiles[bCoord.row][bCoord.col] = tileA.copyWith(
      coordinate: TileCoordinate(row: bCoord.row, col: bCoord.col),
    );

    gridTiles[aCoord.row][aCoord.col] = tileB.copyWith(
      coordinate: TileCoordinate(row: aCoord.row, col: aCoord.col),
    );
  }

  void triggerInitialFall() {
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        gridTiles[r][c].coordinate.row = r;
        gridTiles[r][c].coordinate.col = c;
      }
    }
  }

  bool collectFlyingTiles() {
    Set<TileCoordinate> collected = {};
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        if (gridTiles[r][c].isFlying) {
          collected.add(TileCoordinate(row: r, col: c));
          gridTiles[r][c].isFlying = false;
        }
      }
    }

    if (collected.isEmpty) return false;

    applyGravity(collected);
    return true;
  }

  void applyGravity(Set<TileCoordinate> tilesToDestroy) {
    for (int c = 0; c < cols; c++) {
      List<Tile> remainingTiles = [];
      int destroyedCount = 0;

      for (int r = 0; r < rows; r++) {
        if (tilesToDestroy.any((m) => m.row == r && m.col == c)) {
          destroyedCount++;
        } else {
          remainingTiles.add(gridTiles[r][c]);
        }
      }

      if (destroyedCount == 0) continue;

      List<Tile> skyTiles = List.generate(destroyedCount, (i) {
        final tile = Tile(
          coordinate: TileCoordinate(row: -destroyedCount + i, col: c),
          emoji: level
              .availableEmojis[_random.nextInt(level.availableEmojis.length)],
        );
        return tile;
      });

      List<Tile> newColumn = [...skyTiles, ...remainingTiles];

      for (int r = 0; r < rows; r++) {
        gridTiles[r][c] = newColumn[r];
        gridTiles[r][c].coordinate.col = c;
      }
    }
  }

  ({int x, int y})? findAdjacentEmptyTile(int centerX, int centerY) {
    final List<({int x, int y})> candidates = [];

    for (final (dx, dy) in [(-1, 0), (1, 0), (0, -1), (0, 1)]) {
      final nx = centerX + dx;
      final ny = centerY + dy;

      if (nx >= 0 && nx < rows && ny >= 0 && ny < cols) {
        if (gridTiles[nx][ny].emoji.visual.isEmpty) {
          candidates.add((x: nx, y: ny));
        }
      }
    }

    if (candidates.isEmpty) return null;
    return candidates[_random.nextInt(candidates.length)];
  }

  ({int x, int y})? findAdjacentFilledTile(int centerX, int centerY) {
    final List<({int x, int y})> candidates = [];

    for (final (dx, dy) in [(-1, 0), (1, 0), (0, -1), (0, 1)]) {
      final nx = centerX + dx;
      final ny = centerY + dy;

      if (nx >= 0 && nx < rows && ny >= 0 && ny < cols) {
        if (gridTiles[nx][ny].emoji.visual.isNotEmpty) {
          candidates.add((x: nx, y: ny));
        }
      }
    }

    if (candidates.isEmpty) return null;
    return candidates[_random.nextInt(candidates.length)];
  }

  List<Tile> getAdjacentTiles(int row, int col) {
    final List<Tile> adjacent = [];
    for (final (dx, dy) in [(-1, 0), (1, 0), (0, -1), (0, 1)]) {
      final nx = row + dx;
      final ny = col + dy;
      if (nx >= 0 && nx < rows && ny >= 0 && ny < cols) {
        adjacent.add(gridTiles[nx][ny]);
      }
    }
    return adjacent;
  }

  List<Tile> getTriggeredBombs() {
    final List<Tile> bombs = [];
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        if (gridTiles[r][c].isTriggered) {
          bombs.add(gridTiles[r][c]);
        }
      }
    }
    return bombs;
  }

  ({Set<TileCoordinate> destroyed, Set<TileCoordinate> transformed}) executeBlastRadius(
    TileCoordinate center,
  ) {
    Set<TileCoordinate> destroyedTiles = {};
    Set<TileCoordinate> transformedTiles = {};
    final transformations = RecipeBook.getTransformationsForType(ReactionType.explosive);

    final centerTile = gridTiles[center.row][center.col];
    final centerReaction = RecipeBook.getReactionFor(centerTile.emoji);
    final radius = centerReaction?.aoeRadius ?? 1;

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final rowDist = (r - center.row).abs();
        final colDist = (c - center.col).abs();

        if (rowDist <= radius && colDist <= radius) {
          final tile = gridTiles[r][c];

          final reaction = RecipeBook.getReactionFor(tile.emoji);
          final isExplosive =
              reaction != null && reaction.type == ReactionType.explosive;

          if (isExplosive && (r != center.row || c != center.col)) {
            if (!tile.isExploding) {
              tile.isTriggered = true;
            }
          } else {
            final resultingEmoji = transformations[tile.emoji];
            if (resultingEmoji != null) {
              tile.emoji = resultingEmoji;
              tile.reset(); 
              tile.isTransmuting = true;
              transformedTiles.add(TileCoordinate(row: r, col: c));
            } else {
              tile.isExploding = true;
              destroyedTiles.add(TileCoordinate(row: r, col: c));
            }
          }
        }
      }
    }
    return (destroyed: destroyedTiles, transformed: transformedTiles);
  }
}
