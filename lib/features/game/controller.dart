import 'package:grimoji/config/levels.dart';
import 'package:grimoji/config/emojis.dart';
import 'package:grimoji/features/alchemy/behaviors/behavior.dart';
import 'package:grimoji/features/alchemy/reactions/reaction.dart';
import 'package:grimoji/features/alchemy/recipe_book.dart';
import 'package:grimoji/features/alchemy/behavior_register.dart';
import 'package:grimoji/features/game/model/match_detector.dart';
import 'package:grimoji/features/game/model/swipe_detector.dart';
import 'package:grimoji/features/game/state.dart';
import 'package:grimoji/features/game/model/coordinate.dart';
import 'package:grimoji/features/game/model/tile.dart';
import 'board/manager.dart';
import 'engines/alchemy_engine.dart';
import 'engines/behavior_engine.dart';

class GameController {
  final GameLevel level;

  late final GridManager _gridManager;
  late final AlchemyEngine alchemy;
  late final BehaviorEngine behaviors;

  GameController(this.level) {
    _gridManager = GridManager(level);
    
    alchemy = AlchemyEngine(
      gridManager: _gridManager,
      getRecipes: RecipeBook.getRecipesFor,
      getReactionFor: RecipeBook.getReactionFor,
      getTransformationsForType: RecipeBook.getTransformationsForType,
      getAoERadiusForType: RecipeBook.getAoERadiusForType,
    );
    
    behaviors = BehaviorEngine(
      gridManager: _gridManager,
      getBehavior: BehaviorRegister.getBehaviorFor,
    );
  }

  List<List<Tile>> get grid => _gridManager.gridTiles;

  GridManager get gridManager => _gridManager;

  int getRowCount() => GridManager.rows;
  int getColCount() => GridManager.cols;

  void initialize() {
    RecipeBook.initialize();
    _gridManager.initialize();
  }

  void shuffleGrid() {
    bool validBoard = false;
    
    while (!validBoard) {
      List<GameEmoji> allEmojis = grid
          .expand((row) => row.map((tile) => tile.emoji))
          .toList();
      allEmojis.shuffle();

      int index = 0;
      for (int r = 0; r < getRowCount(); r++) {
        for (int c = 0; c < getColCount(); c++) {
          final tile = grid[r][c];
          tile.emoji = allEmojis[index++];
          tile.reset(); 
          tile.clearBehavior(); 
        }
      }

      validBoard = hasPossibleMoves();
      if (MatchDetector.findMatchedGroups(grid).isNotEmpty) {
        validBoard = false;
      }
    }

    for (int r = 0; r < getRowCount(); r++) {
      for (int c = 0; c < getColCount(); c++) {
        behaviors.initializeBehavior(grid[r][c]);
      }
    }
  }

  void swapTiles(TileCoordinate A, TileCoordinate B) {
    _gridManager.swapTiles(A, B);
  }

  bool hasPossibleMoves() {
    for (int r = 0; r < getRowCount(); r++) {
      for (int c = 0; c < getColCount(); c++) {
        if (c < getColCount() - 1) {
          final d = SwipeDetector.evaluate(
            grid: grid,
            dCoord: TileCoordinate(row: r, col: c),
            tCoord: TileCoordinate(row: r, col: c + 1),
            getSwipeBehaviors: behaviors.processSwipedWithBehavior,
            quickCheckOnly: true,
          );
          if (d.type != SwipeResult.invalid) return true;
        }

        if (r < getRowCount() - 1) {
          final d = SwipeDetector.evaluate(
            grid: grid,
            dCoord: TileCoordinate(row: r, col: c),
            tCoord: TileCoordinate(row: r + 1, col: c),
            getSwipeBehaviors: behaviors.processSwipedWithBehavior,
            quickCheckOnly: true,
          );
          if (d.type != SwipeResult.invalid) return true;
        }
      }
    }
    return false;
  }

  List<TileCoordinate>? getHintMove() {
    for (int r = 0; r < getRowCount(); r++) {
      for (int c = 0; c < getColCount(); c++) {
        if (c < getColCount() - 1) {
          final d = SwipeDetector.evaluate(
            grid: grid,
            dCoord: TileCoordinate(row: r, col: c),
            tCoord: TileCoordinate(row: r, col: c + 1),
            getSwipeBehaviors: behaviors.processSwipedWithBehavior,
            quickCheckOnly: true,
          );
          if (d.type != SwipeResult.invalid) {
            return [
              TileCoordinate(row: r, col: c),
              TileCoordinate(row: r, col: c + 1),
            ];
          }
        }
        if (r < getRowCount() - 1) {
          final d = SwipeDetector.evaluate(
            grid: grid,
            dCoord: TileCoordinate(row: r, col: c),
            tCoord: TileCoordinate(row: r + 1, col: c),
            getSwipeBehaviors: behaviors.processSwipedWithBehavior,
            quickCheckOnly: true,
          );
          if (d.type != SwipeResult.invalid) {
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

  void triggerInitialFall() {
    _gridManager.triggerInitialFall();
  }

  bool collectFlyingTiles() {
    return _gridManager.collectFlyingTiles();
  }

  Set<TileCoordinate> spawnTiles(Set<TileCoordinate> matches, GameState state, {TileCoordinate? mergePoint}) {
    return alchemy.processMatches(matches, state, mergePoint: mergePoint);
  }

  void processTurnEndBehaviors() {
    behaviors.processTurnEndBehaviors();
  }

  void processMatchedBehavior(Tile tile, int x, int y) {
    behaviors.processMatchedBehavior(tile, x, y);
  }

  void processBlastBehavior(Tile tile, int x, int y, ReactionType reactionType) {
    behaviors.processBlastBehavior(tile, x, y, reactionType);
  }

  List<BehaviorAction> processSwipedWithBehavior(Tile tile, int x, int y, GameEmoji targetEmoji) {
    return behaviors.processSwipedWithBehavior(tile, x, y, targetEmoji);
  }

  void executeBehaviorActions(List<BehaviorAction> actions, int centerX, int centerY) {
    behaviors.executeBehaviorActions(actions, centerX, centerY);
  }

  SwipeDecision evaluateSwipe(TileCoordinate dCoord, TileCoordinate tCoord) {
    final decision = SwipeDetector.evaluate(
      grid: grid,
      dCoord: dCoord,
      tCoord: tCoord,
      getSwipeBehaviors: behaviors.processSwipedWithBehavior,
    );

    if (decision.type != SwipeResult.invalid) {
      _gridManager.swapTiles(dCoord, tCoord);
    }

    return decision;
  }

  List<Tile> getTriggeredBombs() => _gridManager.getTriggeredBombs();
  
  ({Set<TileCoordinate> destroyed, Set<TileCoordinate> transformed}) executeBlastRadius(TileCoordinate center, {int radius = 2}) {
    return _gridManager.executeBlastRadius(center, radius: radius);
  }
}
