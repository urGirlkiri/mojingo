import 'package:grimoji/config/emojis.dart';
import 'package:grimoji/features/alchemy/behaviors/behavior.dart';
import 'package:grimoji/features/alchemy/reactions/reaction.dart';
import 'package:grimoji/features/game/model/tile.dart';
import '../board/manager.dart';

class BehaviorEngine {
  final GridManager gridManager;
  
  final EmojiBehavior? Function(GameEmoji) getBehavior;

  BehaviorEngine({
    required this.gridManager,
    required this.getBehavior, 
  });

  void initializeBehavior(Tile tile) {
    final behavior = getBehavior(tile.emoji); 
    if (behavior != null) {
      tile.behavior = behavior;
    }
  }

  void processTurnEndBehaviors() {
    for (int r = 0; r < GridManager.rows; r++) {
      for (int c = 0; c < GridManager.cols; c++) {
        final tile = gridManager.gridTiles[r][c];
        if (tile.behavior != null) {
          final actions = tile.behavior!.onTurnEnd(r, c);
          _executeBehaviorActions(actions, r, c);
        }
      }
    }
  }

  void _executeBehaviorActions(List<BehaviorAction> actions, int centerX, int centerY) {
    for (final action in actions) {
      switch (action.type) {
        case ActionType.placeEmoji:
          final target = gridManager.findAdjacentEmptyTile(centerX, centerY);
          if (target != null && action.emoji != null) {
            gridManager.gridTiles[target.x][target.y].emoji = action.emoji!;
            initializeBehavior(gridManager.gridTiles[target.x][target.y]);
          }
          break;
        case ActionType.transmuteEmoji:
          final target = gridManager.findAdjacentFilledTile(centerX, centerY);
          if (target != null && action.emoji != null) {
            gridManager.gridTiles[target.x][target.y].emoji = action.emoji!;
            gridManager.gridTiles[target.x][target.y].clearBehavior();
          }
          break;
        case ActionType.doNothing:
          break;
      }
    }
  }

  void executeBehaviorActions(List<BehaviorAction> actions, int centerX, int centerY) {
    _executeBehaviorActions(actions, centerX, centerY);
  }

  void processMatchedBehavior(Tile tile, int x, int y) {
    if (tile.behavior != null) {
      tile.behavior!.onMatched(x, y);
    }
  }

  void processBlastBehavior(Tile tile, int x, int y, ReactionType blastType) {
    if (tile.behavior != null) {
      tile.behavior!.onBlastNearby(x, y, blastType);
    }
  }

  List<BehaviorAction> processSwipedWithBehavior(
    Tile tile,
    int x,
    int y,
    GameEmoji targetEmoji,
  ) {
    if (tile.behavior != null) {
      return tile.behavior!.onSwipedWith(x, y, targetEmoji);
    }
    return [];
  }
}