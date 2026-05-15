import 'package:grimoji/config/levels.dart';
import 'package:grimoji/config/emojis.dart';
import 'package:grimoji/features/alchemy/behaviors/behavior.dart';
import 'package:grimoji/features/alchemy/reactions/reaction.dart';
import 'package:grimoji/features/alchemy/recipe_book.dart';
import 'package:grimoji/features/alchemy/behavior_register.dart';
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
      getRecipe: RecipeBook.getRecipeFor,
      getReactions: RecipeBook.getReactionsForType,
    );
    
    behaviors = BehaviorEngine(
      gridManager: _gridManager,
      getBehavior: BehaviorRegister.getBehaviorFor,
    );
  }

  List<List<Tile>> get grid => _gridManager.gridTiles;

  int getRowCount() => GridManager.rows;
  int getColCount() => GridManager.cols;

  void initialize() {
    _gridManager.initialize();
  }

  void swapTiles(TileCoordinate A, TileCoordinate B) {
    _gridManager.swapTiles(A, B);
  }

  bool hasPossibleMoves() {
    return _gridManager.hasPossibleMoves();
  }

  void triggerInitialFall() {
    _gridManager.triggerInitialFall();
  }

  bool collectFlyingTiles() {
    return _gridManager.collectFlyingTiles();
  }

  List<TileCoordinate>? getHintMove() {
    return _gridManager.getHintMove();
  }

  void spawnTiles(Set<TileCoordinate> matches, GameState state, {TileCoordinate? mergePoint}) {
    alchemy.processMatches(matches, state, mergePoint: mergePoint);
  }

  void processTurnEndBehaviors() {
    behaviors.processTurnEndBehaviors();
  }

  void processMatchedBehavior(Tile tile, int x, int y) {
    behaviors.processMatchedBehavior(tile, x, y);
  }

  void processBlastBehavior(Tile tile, int x, int y, ReactionType blastType) {
    behaviors.processBlastBehavior(tile, x, y, blastType);
  }

  List<BehaviorAction> processSwipedWithBehavior(Tile tile, int x, int y, GameEmoji targetEmoji) {
    return behaviors.processSwipedWithBehavior(tile, x, y, targetEmoji);
  }

  void executeBehaviorActions(List<BehaviorAction> actions, int centerX, int centerY) {
    behaviors.executeBehaviorActions(actions, centerX, centerY);
  }
}
