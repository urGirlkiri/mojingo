import 'package:grimoji/config/emojis.dart';
import 'package:grimoji/features/level/game/model/tile.dart';
import 'package:grimoji/features/level/game/model/coordinate.dart';

class MatchGroup {
  final GameEmoji emoji;
  final Set<TileCoordinate> coordinates;

  MatchGroup({required this.emoji, required this.coordinates});
}

class MatchDetector {
  static List<MatchGroup> findMatchGroups(List<List<Tile>> grid) {
    List<MatchGroup> groups = [];
    int rows = grid.length;
    int cols = grid[0].length;

    for (int r = 0; r < rows; r++) {
      int streak = 1;
      for (int c = 0; c < cols; c++) {
        bool isLast = (c == cols - 1);
        bool matchesNext = !isLast && grid[r][c].emoji == grid[r][c + 1].emoji;

        if (matchesNext) {
          streak++;
        } else {
          if (streak >= 3) {
            final coords = <TileCoordinate>{};
            for (int i = 0; i < streak; i++) {
              coords.add(TileCoordinate(row: r, col: c - i));
            }
            groups.add(
              MatchGroup(emoji: grid[r][c].emoji, coordinates: coords),
            );
          }
          streak = 1;
        }
      }
    }

    for (int c = 0; c < cols; c++) {
      int streak = 1;
      for (int r = 0; r < rows; r++) {
        bool isLast = (r == rows - 1);
        bool matchesNext = !isLast && grid[r][c].emoji == grid[r + 1][c].emoji;

        if (matchesNext) {
          streak++;
        } else {
          if (streak >= 3) {
            final coords = <TileCoordinate>{};
            for (int i = 0; i < streak; i++) {
              coords.add(TileCoordinate(row: r - i, col: c));
            }
            groups.add(
              MatchGroup(emoji: grid[r][c].emoji, coordinates: coords),
            );
          }
          streak = 1;
        }
      }
    }

    return groups;
  }
}
