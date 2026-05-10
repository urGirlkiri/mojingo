import 'dart:math';
import 'package:grimoji/config/emojis.dart';
import 'package:grimoji/config/levels.dart';
import 'package:grimoji/features/level/game/model/alchemy/book.dart';
import 'package:grimoji/features/level/game/model/coordinate.dart';
import 'package:grimoji/features/level/game/model/game_state.dart';
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

    _log.info(
      'Available Emojis: ${level.availableEmojis.length}, Emojis: ${level.availableEmojis.map((e) => e.visual).join(', ')}',
    );

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
    for (var row in grid) {
      _log.info(row.map((tile) => tile.emoji.visual).join(' '));
    }
  }

  void triggerInitialFall() {
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        Tile tile = grid[r][c];
        tile.coordinate.row = r;
      }
    }
  }

  void swapTiles(TileCoordinate A, TileCoordinate B) {
    _log.info(
      ' Swapping ${grid[A.row][A.col]}, ${A.col}) with  ${grid[B.row][B.col]}',
    );

    Tile tileA = grid[A.row][A.col];
    Tile tileB = grid[B.row][B.col];

    int originalARow = A.row;
    int originalACol = A.col;

    int originalBRow = B.row;
    int originalBCol = B.col;

    grid[originalARow][originalACol] = tileB;
    grid[originalBRow][originalBCol] = tileA;

    tileA.coordinate.row = originalBRow;
    tileA.coordinate.col = originalBCol;

    tileB.coordinate.row = originalARow;
    tileB.coordinate.col = originalACol;

    _log.info(
      '${grid[tileA.coordinate.row][tileA.coordinate.col]} is now at (${tileA.coordinate.row}, ${tileA.coordinate.col})',
    );
    _log.info(
      '${grid[tileB.coordinate.row][tileB.coordinate.col]} is now at (${tileB.coordinate.row}, ${tileB.coordinate.col})',
    );
  }

void spawnTiles(Set<TileCoordinate> matches, GameState state, {TileCoordinate? mergePoint}) {
    Map<GameEmoji, Set<TileCoordinate>> groupedMatches = {};
    for (var match in matches) {
      GameEmoji emoji = grid[match.row][match.col].emoji;
      groupedMatches.putIfAbsent(emoji, () => {}).add(match);
    }

    Set<TileCoordinate> tilesToDestroy = {};
    Set<TileCoordinate> transmutedTiles = {}; 

    groupedMatches.forEach((emoji, coords) {
      state.resolveEmoji(emoji, coords.length);
      Recipe? recipe = RecipeBook.getRecipeFor(emoji);

      if (recipe != null && recipe.type == RecipeType.merge && recipe.yields != null) {
        TileCoordinate spawnPoint = coords.contains(mergePoint) ? mergePoint! : coords.first;
        
        grid[spawnPoint.row][spawnPoint.col].emoji = recipe.yields!;
        
        grid[spawnPoint.row][spawnPoint.col].reset(); 

        if (recipe.yields == state.level.targetEmoji) {
          state.resolveEmoji(recipe.yields!, 1); 
        }
        tilesToDestroy.addAll(coords.where((c) => c != spawnPoint));
      } 
      
      else if (recipe != null && recipe.type == RecipeType.volatile) {
        _log.info('💥 SPELL DETONATED!');
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
      else {
        tilesToDestroy.addAll(coords);
      }
    });

    tilesToDestroy.removeWhere((coord) => transmutedTiles.contains(coord));

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

      List<Tile> skyTiles = [];
      for (int i = 0; i < destroyedCount; i++) {
        skyTiles.add(Tile(
          coordinate: TileCoordinate(row: -destroyedCount + i, col: c),
          emoji: level.availableEmojis[_random.nextInt(level.availableEmojis.length)],
        ));
      }

      List<Tile> newColumn = [...skyTiles, ...remainingTiles];

      for (int r = 0; r < rows; r++) {
        grid[r][c] = newColumn[r];
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

      if (col <= 1) {
        _log.info(
          'At The Col $col, No Two Emojis To The Left, skipping horizontal check',
        );
      } else {
        if (grid[row][col - 1].emoji == candidate &&
            grid[row][col - 2].emoji == candidate) {
          isSafe = false;
        }
      }

      if (row <= 1) {
        _log.info(
          'At The Row $row, No Two Emojis Above, skipping vertical check',
        );
      } else {
        if (grid[row - 1][col].emoji == candidate &&
            grid[row - 2][col].emoji == candidate) {
          isSafe = false;
        }
      }
    }
    return candidate;
  }
}
