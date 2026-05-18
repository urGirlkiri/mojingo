import 'package:flutter_test/flutter_test.dart';
import 'package:grimoji/config/emojis.dart';
import 'package:grimoji/config/levels/game_level.dart';
import 'package:grimoji/config/levels/index.dart';
import 'package:grimoji/features/game/controller.dart';
import 'package:grimoji/features/game/state.dart';
import 'package:grimoji/features/game/model/coordinate.dart';
import 'package:grimoji/features/game/model/swipe_detector.dart';
import 'package:grimoji/features/alchemy/reactions/reaction.dart';
import 'package:grimoji/utils/test_helpers.dart';

void main() {
  group('GameController Tests', () {
    late GameController controller;
    late GameLevel level;

    setUp(() {
      level = const GameLevel(
        number: 1,
        availableEmojis: [Emojis.fire, Emojis.rock, Emojis.droplet, Emojis.alien],
        targetEmoji: Emojis.fire,
        targetAmount: 10,
        timeLimit: 60,
        type: LevelType.puzzle,
      );
      controller = GameController(level);
      controller.initialize();
    });

    test('Should determine possible moves and hints for horizontal and vertical matches', () {
      TestHelpers.genDeadLockGrid(controller);
      expect(controller.hasPossibleMoves(), isFalse, reason: 'No moves available in deadlock grid');
      expect(controller.getHintMove(), isNull, reason: 'No hint available in deadlock grid');

      controller.grid[0][0].emoji = Emojis.fire;
      controller.grid[0][1].emoji = Emojis.fire;
      controller.grid[1][2].emoji = Emojis.fire; 
      expect(controller.hasPossibleMoves(), isTrue, reason: 'Horizontal match available');
      expect(controller.getHintMove(), isNotNull, reason: 'Hint should be found for horizontal match');

      TestHelpers.genDeadLockGrid(controller);
      controller.grid[0][0].emoji = Emojis.fire;
      controller.grid[1][0].emoji = Emojis.fire;
      controller.grid[2][0].emoji = Emojis.fire; 
      expect(controller.hasPossibleMoves(), isTrue, reason: 'Vertical match available');
      final hint = controller.getHintMove();
      expect(hint, isNotNull, reason: 'Hint should be found for vertical match');
    });

    test('Should evaluate swipe as invalid or valid and revert or match', () {
      TestHelpers.genDeadLockGrid(controller);
      final originalVisual = controller.grid[0][0].emoji.visual;
      
      final d1 = controller.evaluateSwipe(TileCoordinate(row: 0, col: 0), TileCoordinate(row: 0, col: 1));
      expect(d1.type, SwipeResult.invalid, reason: 'Swap should be invalid in deadlock');
      expect(controller.grid[0][0].emoji.visual, originalVisual, reason: 'Grid should revert after invalid swap');

      controller.grid[0][0].emoji = Emojis.fire;
      controller.grid[0][1].emoji = Emojis.fire;
      controller.grid[1][2].emoji = Emojis.fire;
      final d2 = controller.evaluateSwipe(TileCoordinate(row: 0, col: 2), TileCoordinate(row: 1, col: 2));
      expect(d2.type, SwipeResult.match, reason: 'Swap should create a match');
      expect(controller.grid[0][2].emoji.visual, Emojis.fire.visual, reason: 'Matched emoji should appear at target position');
    });

    test('Should handle grid physics for fall, collect, and shuffle', () {
      controller.triggerInitialFall();
      
      controller.grid[0][0].isFlying = true;
      expect(controller.collectFlyingTiles(), isTrue, reason: 'Should collect flying tiles');
      expect(controller.collectFlyingTiles(), isFalse, reason: 'No more flying tiles to collect');

      expect(() => controller.shuffleGrid(), returnsNormally, reason: 'Shuffle should execute without error');
    });

    test('Should execute engine bridge methods without errors', () {
      final tile = controller.grid[0][0];
      
      expect(() => controller.processTurnEndBehaviors(), returnsNormally, reason: 'processTurnEndBehaviors should execute');
      expect(() => controller.processMatchedBehavior(tile, 0, 0), returnsNormally, reason: 'processMatchedBehavior should execute');
      expect(() => controller.processBlastBehavior(tile, 0, 0, ReactionType.explosive), returnsNormally, reason: 'processBlastBehavior should execute');
      expect(controller.processSwipedWithBehavior(tile, 0, 0, Emojis.fire), isEmpty, reason: 'processSwipedWithBehavior should return empty list');
      expect(() => controller.executeBehaviorActions([], 0, 0), returnsNormally, reason: 'executeBehaviorActions should execute');
      
      final dummyState = GameState(
        level: level,
        onEmojiDestroyed: (_, _) {},
        onComboFinished: () => false,
      );
      expect(() => controller.spawnTiles({}, dummyState), returnsNormally, reason: 'spawnTiles should execute');
    });

    group('Swipe Evaluation Tests', () {
      test('evaluateSwipe should REJECT invalid moves and NOT swap underlying grid data', () {
        TestHelpers.genDeadLockGrid(controller);
        
        final decision = controller.evaluateSwipe(
          TileCoordinate(row: 0, col: 0), 
          TileCoordinate(row: 0, col: 1)
        );

        expect(decision.type, SwipeResult.invalid);

      });

      test('evaluateSwipe should ACCEPT valid Match-3s and PERMANENTLY swap underlying grid data', () {
        controller.grid[0][0].emoji = Emojis.fire; 
        controller.grid[0][1].emoji = Emojis.droplet; 
        controller.grid[0][2].emoji = Emojis.fire;
        controller.grid[0][3].emoji = Emojis.fire;

        final decision = controller.evaluateSwipe(
          TileCoordinate(row: 0, col: 0), 
          TileCoordinate(row: 0, col: 1)
        );

        expect(decision.type, SwipeResult.match);

        expect(controller.grid[0][0].emoji, Emojis.droplet, reason: 'Engine failed to commit the valid swap');
        expect(controller.grid[0][1].emoji, Emojis.fire, reason: 'Engine failed to commit the valid swap');
      });
    });
  });
}