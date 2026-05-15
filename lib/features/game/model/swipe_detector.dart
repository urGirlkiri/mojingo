import 'package:grimoji/config/emojis.dart';
import 'package:grimoji/features/alchemy/behaviors/behavior.dart';
import 'package:grimoji/features/game/model/coordinate.dart';
import 'package:grimoji/features/game/model/match_detector.dart';
import 'package:grimoji/features/game/model/tile.dart';

enum SwipeResultType { match, specialBehavior, invalid }

class SwipeDecision {
  final SwipeResultType type;
  final List<MatchGroup> matches;
  final List<BehaviorAction> actions;

  SwipeDecision({required this.type, this.matches = const [], this.actions = const []});
}

class SwipeDetector {
  static SwipeDecision evaluate({
    required List<List<Tile>> grid,
    required TileCoordinate dCoord,
    required TileCoordinate tCoord,
    required List<BehaviorAction> Function(Tile, int, int, GameEmoji) getSwipeBehaviors,
    bool quickCheckOnly = false,
  }) {
    final tileD = grid[dCoord.row][dCoord.col];
    final tileT = grid[tCoord.row][tCoord.col];

    final actionsD = getSwipeBehaviors(tileT, dCoord.row, dCoord.col, tileD.emoji);
    final actionsT = getSwipeBehaviors(tileD, tCoord.row, tCoord.col, tileT.emoji);

    if (actionsD.isNotEmpty || actionsT.isNotEmpty) {
      return SwipeDecision(
        type: SwipeResultType.specialBehavior,
        actions: [...actionsD, ...actionsT],
      );
    }

    _tempSwap(grid, dCoord, tCoord);

    SwipeDecision decision;

    if (quickCheckOnly) {
      final hasMatch = MatchDetector.hasMatchAt(grid, dCoord.row, dCoord.col) ||
                       MatchDetector.hasMatchAt(grid, tCoord.row, tCoord.col);

      decision = hasMatch
          ? SwipeDecision(type: SwipeResultType.match)
          : SwipeDecision(type: SwipeResultType.invalid);
    } else {
      final matchGroups = MatchDetector.findMatchGroups(grid);
      decision = matchGroups.isNotEmpty
          ? SwipeDecision(type: SwipeResultType.match, matches: matchGroups)
          : SwipeDecision(type: SwipeResultType.invalid);
    }

    _tempSwap(grid, dCoord, tCoord);

    return decision;
  }

  static void _tempSwap(List<List<Tile>> grid, TileCoordinate a, TileCoordinate b) {
    final temp = grid[a.row][a.col];
    grid[a.row][a.col] = grid[b.row][b.col];
    grid[b.row][b.col] = temp;
  }
}