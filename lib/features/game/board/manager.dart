import 'dart:math';
import 'package:grimoji/config/levels.dart';
import 'package:grimoji/config/emojis.dart';
import 'package:grimoji/features/game/model/tile.dart';
import 'package:grimoji/features/game/model/coordinate.dart';

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

  void swapTiles(TileCoordinate A, TileCoordinate B) {
    Tile tileA = gridTiles[A.row][A.col];
    Tile tileB = gridTiles[B.row][B.col];

    gridTiles[A.row][A.col] = tileB;
    gridTiles[B.row][B.col] = tileA;

    tileA.coordinate.row = B.row;
    tileA.coordinate.col = B.col;

    tileB.coordinate.row = A.row;
    tileB.coordinate.col = A.col;
  }

  void triggerInitialFall() {
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        gridTiles[r][c].coordinate.row = r;
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
}