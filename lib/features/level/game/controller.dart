import 'dart:math';
import 'package:grimoji/config/emojis.dart';
import 'package:grimoji/features/level/game/model/coordinate.dart';
import 'package:grimoji/features/level/game/model/tile.dart';
import 'package:logging/logging.dart';

class GameController {
  static const int rows = 8;
  static const int cols = 5;
  
  late List<List<Tile>> grid;
  late List<GameEmoji> availableEmojis;

  final Random _random = Random();
  final Logger _log = Logger('GameController');

  void initialize() {
    _log.info('Initializing GameController');
    availableEmojis = [
      Emojis.droplet, 
      Emojis.fire, 
      Emojis.bomb, 
      Emojis.exhale, 
      Emojis.salt
    ];
    _log.info('Available Emojis: ${availableEmojis.length}, Emojis: ${availableEmojis.map((e) => e.visual).join(', ')}');

    grid = List.generate(
      rows, 
      (r) => List.generate(
        cols, 
        (c) => Tile(
          coordinate: TileCoordinate(row: r, col: c), 
          emoji: availableEmojis[0])
      )
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

  int getRowCount() => rows;
  int getColCount() => cols;
  
  GameEmoji _getRandomSafeEmoji(int row, int col) {
    
    GameEmoji candidate = availableEmojis[0];
    bool isSafe = false;

    while (!isSafe) {
      candidate = availableEmojis[_random.nextInt(availableEmojis.length)];
      isSafe = true;

      if (col <= 1) {
        _log.info('At The Col $col, No Two Emojis To The Left, skipping horizontal check');
      } else {
        if (grid[row][col - 1].emoji == candidate && grid[row][col - 2].emoji == candidate) {
          isSafe = false;
        }
      }

      if (row <= 1) {
        _log.info('At The Row $row, No Two Emojis Above, skipping vertical check');
      } else {
        if (grid[row - 1][col].emoji == candidate && grid[row - 2][col].emoji == candidate) {
          isSafe = false;
        }
      }
    }
    return candidate;
  }
}