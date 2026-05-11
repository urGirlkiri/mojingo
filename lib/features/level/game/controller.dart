import 'dart:math';
import 'package:grimoji/config/emojis.dart';
import 'package:grimoji/config/levels.dart';
import 'package:grimoji/features/level/game/model/alchemy/book.dart';
import 'package:grimoji/features/level/game/model/coordinate.dart';
import 'package:grimoji/features/level/game/model/game_state.dart';
import 'package:grimoji/features/level/game/model/match_detector.dart';
import 'package:grimoji/features/level/game/model/tile.dart';
import 'package:logging/logging.dart';

class GameController {
  static const int rows = 8;
  static const int cols = 5;

  late List<List<Tile>> grid;
  late GameLevel level;

  final Random _random = Random();
  final Logger _log = Logger('GameController');

  GameController(this.level);

  int getRowCount() => rows;
  int getColCount() => cols;

  void initialize() {
    _log.info('Initializing GameController');

    grid = List.generate(
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
        grid[r][c].emoji = _getRandomSafeEmoji(r, c);
      }
    }
    _log.info('Game Grid Initialized');
  }

  bool hasPossibleMoves() {
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        if (c < cols - 1) {
          _simulateSwap(r, c, r, c + 1);
          bool hasMatch = MatchDetector.findMatchGroups(grid).isNotEmpty;
          _simulateSwap(r, c, r, c + 1);
          if (hasMatch) return true;
        }

        if (r < rows - 1) {
          _simulateSwap(r, c, r + 1, c);
          bool hasMatch = MatchDetector.findMatchGroups(grid).isNotEmpty;
          _simulateSwap(r, c, r + 1, c);
          if (hasMatch) return true;
        }
      }
    }
    return false;
  }

  void triggerInitialFall() {
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        grid[r][c].coordinate.row = r;
      }
    }
  }

  void swapTiles(TileCoordinate A, TileCoordinate B) {
    Tile tileA = grid[A.row][A.col];
    Tile tileB = grid[B.row][B.col];

    grid[A.row][A.col] = tileB;
    grid[B.row][B.col] = tileA;

    tileA.coordinate.row = B.row;
    tileA.coordinate.col = B.col;

    tileB.coordinate.row = A.row;
    tileB.coordinate.col = A.col;
  }

  void spawnTiles(
    Set<TileCoordinate> matches,
    GameState state, {
    TileCoordinate? mergePoint,
  }) {
    Set<TileCoordinate> tilesToDestroy = {};
    Set<TileCoordinate> transmutedTiles = {};

    _processMatches(
      matches,
      state,
      tilesToDestroy,
      transmutedTiles,
      mergePoint,
    );

    tilesToDestroy.removeWhere((coord) => transmutedTiles.contains(coord));

    _applyGravity(tilesToDestroy);
  }

  void _processMatches(
    Set<TileCoordinate> matches,
    GameState state,
    Set<TileCoordinate> tilesToDestroy,
    Set<TileCoordinate> transmutedTiles,
    TileCoordinate? mergePoint,
  ) {
    Map<GameEmoji, Set<TileCoordinate>> groupedMatches = {};
    for (var match in matches) {
      GameEmoji emoji = grid[match.row][match.col].emoji;
      groupedMatches.putIfAbsent(emoji, () => {}).add(match);
    }

    groupedMatches.forEach((emoji, coords) {
      state.resolveEmoji(emoji, coords.length);
      Recipe? recipe = RecipeBook.getRecipeFor(emoji);

      if (recipe != null &&
          recipe.type == RecipeType.merge &&
          recipe.yields != null) {
        _executeMerge(recipe, coords, state, tilesToDestroy, mergePoint);
      } else if (recipe != null && recipe.type == RecipeType.volatile) {
        _executClear(coords, tilesToDestroy, transmutedTiles);
      } else {
        tilesToDestroy.addAll(coords);
      }
    });
  }

  void _executeMerge(
    Recipe recipe,
    Set<TileCoordinate> coords,
    GameState state,
    Set<TileCoordinate> tilesToDestroy,
    TileCoordinate? mergePoint,
  ) {
    TileCoordinate spawnPoint = coords.contains(mergePoint)
        ? mergePoint!
        : coords.first;
    Tile targetTile = grid[spawnPoint.row][spawnPoint.col];

    targetTile.emoji = recipe.yields!;
    targetTile.reset();

    if (recipe.yields == state.level.targetEmoji) {
      state.resolveEmoji(recipe.yields!, 1);
      targetTile.isFlying = true;
    }

    tilesToDestroy.addAll(coords.where((c) => c != spawnPoint));
  }

  void _executClear(
    Set<TileCoordinate> coords,
    Set<TileCoordinate> tilesToDestroy,
    Set<TileCoordinate> transmutedTiles,
  ) {
    _log.info('DETONATED!');
    tilesToDestroy.addAll(coords);

    for (var bombCoord in coords) {
      for (int r = bombCoord.row - 1; r <= bombCoord.row + 1; r++) {
        for (int c = bombCoord.col - 1; c <= bombCoord.col + 1; c++) {
          if (r >= 0 && r < rows && c >= 0 && c < cols) {
            Tile targetTile = grid[r][c];
            TileCoordinate targetCoord = TileCoordinate(row: r, col: c);

            if (RecipeBook.transmutations.containsKey(targetTile.emoji)) {
              targetTile.emoji = RecipeBook.transmutations[targetTile.emoji]!;
              targetTile.reset();
              transmutedTiles.add(targetCoord);
            } else if (!coords.contains(targetCoord)) {
              tilesToDestroy.add(targetCoord);
            }
          }
        }
      }
    }
  }

  bool collectFlyingTiles() {
    Set<TileCoordinate> collected = {};
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        if (grid[r][c].isFlying) {
          collected.add(TileCoordinate(row: r, col: c));
          grid[r][c].isFlying = false;
        }
      }
    }

    if (collected.isEmpty) return false;

    _applyGravity(collected);
    return true;
  }

  List<TileCoordinate>? getHintMove() {
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        if (c < cols - 1) {
          _simulateSwap(r, c, r, c + 1);
          bool hasMatch = MatchDetector.findMatchGroups(grid).isNotEmpty;
          _simulateSwap(r, c, r, c + 1);
          if (hasMatch) {
            return [
              TileCoordinate(row: r, col: c),
              TileCoordinate(row: r, col: c + 1),
            ];
          }
        }

        if (r < rows - 1) {
          _simulateSwap(r, c, r + 1, c);
          bool hasMatch = MatchDetector.findMatchGroups(grid).isNotEmpty;
          _simulateSwap(r, c, r + 1, c);
          if (hasMatch) {
            return [
              TileCoordinate(row: r, col: c),
              TileCoordinate(row: r + 1, col: c),
            ];
          }
        }
      }
    }
    return null;
  }

  void _applyGravity(Set<TileCoordinate> tilesToDestroy) {
    for (int c = 0; c < cols; c++) {
      List<Tile> remainingTiles = [];
      int destroyedCount = 0;

      for (int r = 0; r < rows; r++) {
        if (tilesToDestroy.any((m) => m.row == r && m.col == c)) {
          destroyedCount++;
        } else {
          remainingTiles.add(grid[r][c]);
        }
      }

      if (destroyedCount == 0) continue;

      List<Tile> skyTiles = List.generate(destroyedCount, (i) {
        return Tile(
          coordinate: TileCoordinate(row: -destroyedCount + i, col: c),
          emoji: level
              .availableEmojis[_random.nextInt(level.availableEmojis.length)],
        );
      });

      List<Tile> newColumn = [...skyTiles, ...remainingTiles];

      for (int r = 0; r < rows; r++) {
        grid[r][c] = newColumn[r];
      }
    }
  }

  void _simulateSwap(int r1, int c1, int r2, int c2) {
    Tile temp = grid[r1][c1];
    grid[r1][c1] = grid[r2][c2];
    grid[r2][c2] = temp;
  }

  GameEmoji _getRandomSafeEmoji(int row, int col) {
    GameEmoji candidate = level.availableEmojis[0];
    bool isSafe = false;

    while (!isSafe) {
      candidate =
          level.availableEmojis[_random.nextInt(level.availableEmojis.length)];
      isSafe = true;

      if (col > 1 &&
          grid[row][col - 1].emoji == candidate &&
          grid[row][col - 2].emoji == candidate) {
        isSafe = false;
      }
      if (row > 1 &&
          grid[row - 1][col].emoji == candidate &&
          grid[row - 2][col].emoji == candidate) {
        isSafe = false;
      }
    }
    return candidate;
  }
}
