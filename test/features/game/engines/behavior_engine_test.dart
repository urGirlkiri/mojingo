import 'package:flutter_test/flutter_test.dart';
import 'package:grimoji/config/emojis.dart';
import 'package:grimoji/config/levels/game_level.dart';
import 'package:grimoji/config/levels/index.dart';
import 'package:grimoji/features/alchemy/behaviors/behavior.dart';
import 'package:grimoji/features/alchemy/reactions/reaction.dart';
import 'package:grimoji/features/game/board/manager.dart';
import 'package:grimoji/features/game/engines/behavior_engine.dart';
import 'package:grimoji/features/game/model/coordinate.dart';
import 'package:grimoji/features/game/model/tile.dart';

class SpyBehavior extends EmojiBehavior {
  bool matchedCalled = false;
  bool blastCalled = false;
  bool swipedCalled = false;
  
  List<BehaviorAction> turnEndActionsToReturn = [];
  List<BehaviorAction> swipedActionsToReturn = [];

  @override
  List<BehaviorAction> onTurnEnd(int x, int y) {
    return turnEndActionsToReturn;
  }

  @override
  List<BehaviorAction> onMatched(int x, int y) {
    matchedCalled = true;
    return [];
  }

  @override
  List<BehaviorAction> onBlastNearby(int x, int y, ReactionType reactionType) {
    blastCalled = true;
    return [];
  }

  @override
  List<BehaviorAction> onSwipedWith(int x, int y, GameEmoji targetEmoji) {
    swipedCalled = true;
    return swipedActionsToReturn;
  }
}

void main() {
  group('BehaviorEngine Tests', () {
    late GridManager gridManager;
    late BehaviorEngine behaviorEngine;
    late SpyBehavior spyBehavior;

    setUp(() {
      final testLevel = const GameLevel(
        number: 1,
        timeLimit: 60,
        targetEmoji: Emojis.ocean,
        targetAmount: 1,
        availableEmojis: [Emojis.rock, Emojis.bug, Emojis.alien],
        type: LevelType.puzzle,
      );
      
      gridManager = GridManager(testLevel);
      gridManager.initialize();
      
      spyBehavior = SpyBehavior();

      behaviorEngine = BehaviorEngine(
        gridManager: gridManager,
        getBehavior: (emoji) {
          if (emoji == Emojis.bug) {
            return spyBehavior; 
          }
          return null;
        },
      );
    });

    test('initializeBehavior should assign behavior if it exists, and do nothing if null', () {
      final bugTile = Tile(coordinate: TileCoordinate(row: 0, col: 0), emoji: Emojis.bug);
      final rockTile = Tile(coordinate: TileCoordinate(row: 0, col: 1), emoji: Emojis.rock);

      behaviorEngine.initializeBehavior(bugTile);
      behaviorEngine.initializeBehavior(rockTile);

      expect(bugTile.behavior, isNotNull, reason: 'Bug should get the SpyBehavior assigned');
      expect(rockTile.behavior, isNull, reason: 'Rock should have no behavior');
    });

    group('Event Triggers', () {
      test('processMatchedBehavior safely handles tiles with and without behaviors', () {
        final bugTile = Tile(coordinate: TileCoordinate(row: 0, col: 0), emoji: Emojis.bug);
        behaviorEngine.initializeBehavior(bugTile);

        behaviorEngine.processMatchedBehavior(bugTile, 0, 0);
        expect(spyBehavior.matchedCalled, isTrue, reason: 'Engine should trigger onMatched');

        final rockTile = Tile(coordinate: TileCoordinate(row: 0, col: 0), emoji: Emojis.rock);
        expect(() => behaviorEngine.processMatchedBehavior(rockTile, 0, 0), returnsNormally,
          reason: 'Engine should safely ignore tiles without behaviors');
      });

      test('processBlastBehavior safely handles tiles with and without behaviors', () {
        final bugTile = Tile(coordinate: TileCoordinate(row: 0, col: 0), emoji: Emojis.bug);
        behaviorEngine.initializeBehavior(bugTile);

        behaviorEngine.processBlastBehavior(bugTile, 0, 0, ReactionType.explosive);
        expect(spyBehavior.blastCalled, isTrue, reason: 'Engine should trigger onBlastNearby');

        final rockTile = Tile(coordinate: TileCoordinate(row: 0, col: 0), emoji: Emojis.rock);
        expect(() => behaviorEngine.processBlastBehavior(rockTile, 0, 0, ReactionType.explosive), returnsNormally,
          reason: 'Engine should safely ignore tiles without behaviors');
      });

      test('processSwipedWithBehavior returns actions if behavior exists, else empty list', () {
        final bugTile = Tile(coordinate: TileCoordinate(row: 0, col: 0), emoji: Emojis.bug);
        behaviorEngine.initializeBehavior(bugTile);
        
        spyBehavior.swipedActionsToReturn = [
          const BehaviorAction(type: ActionType.doNothing, x: 0, y: 0)
        ];

        final actions = behaviorEngine.processSwipedWithBehavior(bugTile, 0, 0, Emojis.fire);
        expect(spyBehavior.swipedCalled, isTrue, reason: 'Engine should trigger onSwipedWith');
        expect(actions.length, 1, reason: 'Should return the actions provided by the behavior');
        expect(actions.first.type, ActionType.doNothing, reason: 'Returned action should be the one defined in the SpyBehavior');

        final rockTile = Tile(coordinate: TileCoordinate(row: 0, col: 0), emoji: Emojis.rock);
        final noActions = behaviorEngine.processSwipedWithBehavior(rockTile, 0, 0, Emojis.fire);
        expect(noActions, isEmpty, reason: 'Normal tiles should return an empty action list');
      });
    });

    group('Action Execution Logic', () {
      test('ActionType.placeEmoji should clone the emoji into an adjacent empty tile', () {
        const emptyEmoji = GameEmoji('svg/empty.svg', 'lottie/empty.json', '');
        gridManager.gridTiles[1][1].emoji = Emojis.bug;
        behaviorEngine.initializeBehavior(gridManager.gridTiles[1][1]);
        
        gridManager.gridTiles[0][1].emoji = emptyEmoji;
        gridManager.gridTiles[2][1].emoji = emptyEmoji;
        gridManager.gridTiles[1][0].emoji = emptyEmoji;
        gridManager.gridTiles[1][2].emoji = emptyEmoji;

        spyBehavior.turnEndActionsToReturn = [
          const BehaviorAction(type: ActionType.placeEmoji, x: 1, y: 1, emoji: Emojis.bug)
        ];

        behaviorEngine.processTurnEndBehaviors();

        final neighbors = [
          gridManager.gridTiles[0][1].emoji,
          gridManager.gridTiles[2][1].emoji,
          gridManager.gridTiles[1][0].emoji,
          gridManager.gridTiles[1][2].emoji,
        ];
        expect(neighbors.contains(Emojis.bug), isTrue, reason: 'Engine should place a new Bug');
      });

      test('ActionType.reactEmoji should overwrite a filled neighbor and clear its behavior', () {
        gridManager.gridTiles[1][1].emoji = Emojis.bug;
        
        gridManager.gridTiles[0][1].emoji = Emojis.rock;
        gridManager.gridTiles[2][1].emoji = Emojis.rock;
        gridManager.gridTiles[1][0].emoji = Emojis.rock;
        gridManager.gridTiles[1][2].emoji = Emojis.rock;
        
        gridManager.gridTiles[0][1].behavior = SpyBehavior();
        
        final transmuteAction = [const BehaviorAction(type: ActionType.reactEmoji, x: 1, y: 1, emoji: Emojis.cloud)];
        behaviorEngine.executeBehaviorActions(transmuteAction, 1, 1);

        final neighbors = [
          gridManager.gridTiles[0][1],
          gridManager.gridTiles[2][1],
          gridManager.gridTiles[1][0],
          gridManager.gridTiles[1][2],
        ];
        
        final transmutedTiles = neighbors.where((n) => n.emoji == Emojis.cloud).toList();
        expect(transmutedTiles.length, 1, reason: 'One of the neighbor rocks should have become a Cloud');
        expect(transmutedTiles.first.behavior, isNull, reason: 'The transmuted tile must have its behavior wiped');
      });

      test('Should safely handle ActionType.doNothing', () {
        final actions = [const BehaviorAction(type: ActionType.doNothing, x: 0, y: 0)];
        expect(() => behaviorEngine.executeBehaviorActions(actions, 0, 0), returnsNormally, 
          reason: 'Engine should safely ignore doNothing actions without error');
      });

      test('Should safely ignore invalid actions (null emojis or no available targets)', () {
        final nullEmojiAction = [const BehaviorAction(type: ActionType.placeEmoji, x: 1, y: 1, emoji: null)];
        expect(() => behaviorEngine.executeBehaviorActions(nullEmojiAction, 1, 1), returnsNormally, 
          reason: 'Engine should safely ignore actions with null emojis without error');

        final placeAction = [const BehaviorAction(type: ActionType.placeEmoji, x: 1, y: 1, emoji: Emojis.bug)];
        expect(() => behaviorEngine.executeBehaviorActions(placeAction, 1, 1), returnsNormally, 
          reason: 'Engine should safely execute valid placeEmoji actions without error');

        const emptyEmoji = GameEmoji('svg/empty.svg', 'lottie/empty.json', '');
        for (int r = 0; r < GridManager.rows; r++) {
          for (int c = 0; c < GridManager.cols; c++) {
            gridManager.gridTiles[r][c].emoji = emptyEmoji;
          }
        }
        final transmuteAction = [const BehaviorAction(type: ActionType.reactEmoji, x: 1, y: 1, emoji: Emojis.cloud)];
        expect(() => behaviorEngine.executeBehaviorActions(transmuteAction, 1, 1), returnsNormally, 
          reason: 'Engine should safely ignore transmute actions with no available targets without error');
      });
    });
  });
}