import 'dart:math';
import 'package:grimoji/config/emojis.dart';
import 'package:grimoji/config/levels.dart';
import 'package:grimoji/features/level/game/model/coordinate.dart';
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
    _log.info('Dropping emojis');
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        Tile tile = grid[r][c];
        _log.info(
          "Emoji: ${tile.emoji.visual}, Dropped From, ${tile.coordinate.row} to $r",
        );
        tile.coordinate.row = r;
      }
    }
  }

void swapTiles(TileCoordinate A, TileCoordinate B) {
    _log.info(' Swapping ${grid[A.row][A.col]}, ${A.col}) with  ${grid[B.row][B.col]}');

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

    _log.info('${grid[tileA.coordinate.row][tileA.coordinate.col]} is now at (${tileA.coordinate.row}, ${tileA.coordinate.col})');
    _log.info('${grid[tileB.coordinate.row][tileB.coordinate.col]} is now at (${tileB.coordinate.row}, ${tileB.coordinate.col})');
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
