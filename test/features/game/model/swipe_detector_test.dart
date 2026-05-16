import 'package:flutter_test/flutter_test.dart';
import 'package:grimoji/config/emojis.dart';
import 'package:grimoji/features/alchemy/behaviors/behavior.dart';
import 'package:grimoji/features/game/model/coordinate.dart';
import 'package:grimoji/features/game/model/swipe_detector.dart';
import 'package:grimoji/features/game/model/tile.dart';

void main() {
  group('SwipeDetector Test', () {
    
    List<List<Tile>> createTestGrid() {
      return List.generate(
        3,
        (r) => List.generate(
          3,
          (c) => Tile(
            coordinate: TileCoordinate(row: r, col: c),
            emoji: (r + c) % 2 == 0 ? Emojis.fire : Emojis.rock,
          ),
        ),
      );
    }

    test('Should return invalid if no match or behavior is found ', () {
      final grid = createTestGrid(); 
      
      final decision = SwipeDetector.evaluate(
        grid: grid,
        dCoord: TileCoordinate(row: 0, col: 0),
        tCoord: TileCoordinate(row: 0, col: 1),
        getSwipeBehaviors: (_, _, _, _) => [],
      );

      expect(decision.type, equals(SwipeResult.invalid));
    });

    test('Should detect a match using quickCheckOnly: true', () {
      final grid = createTestGrid();
      grid[0][0].emoji = Emojis.fire;
      grid[0][1].emoji = Emojis.fire;
      grid[1][2].emoji = Emojis.fire; 

      final decision = SwipeDetector.evaluate(
        grid: grid,
        dCoord: TileCoordinate(row: 0, col: 2),
        tCoord: TileCoordinate(row: 1, col: 2),
        getSwipeBehaviors: (_, _, _, _) => [],
        quickCheckOnly: true, 
      );

      expect(decision.type, equals(SwipeResult.match));
      expect(decision.matches, isEmpty, reason: 'QuickCheck doesn\'t return group data');
    });

    test('Should return invalid using quickCheckOnly: true if move fails', () {
      final grid = createTestGrid();
      final decision = SwipeDetector.evaluate(
        grid: grid,
        dCoord: TileCoordinate(row: 0, col: 0),
        tCoord: TileCoordinate(row: 0, col: 1),
        getSwipeBehaviors: (_, _, _, _) => [],
        quickCheckOnly: true,
      );

      expect(decision.type, equals(SwipeResult.invalid));
    });

    test('Should detect a valid HORIZONTAL match-3', () {
      final grid = createTestGrid();
      grid[0][0].emoji = Emojis.fire;
      grid[0][1].emoji = Emojis.fire;
      grid[0][2].emoji = Emojis.rock;
      grid[1][2].emoji = Emojis.fire; 

      final decision = SwipeDetector.evaluate(
        grid: grid,
        dCoord: TileCoordinate(row: 0, col: 2),
        tCoord: TileCoordinate(row: 1, col: 2),
        getSwipeBehaviors: (_, _, _, _) => [],
      );

      expect(decision.type, equals(SwipeResult.match));
      expect(decision.matches.first.emoji, equals(Emojis.fire));
      expect(decision.matches.first.coordinates.length, equals(3));
    });

    test('Should detect a valid VERTICAL match-3', () {
      final grid = createTestGrid();
      grid[0][0].emoji = Emojis.fire;
      grid[1][0].emoji = Emojis.fire;
      grid[2][0].emoji = Emojis.rock;
      grid[2][1].emoji = Emojis.fire;

      final decision = SwipeDetector.evaluate(
        grid: grid,
        dCoord: TileCoordinate(row: 2, col: 0),
        tCoord: TileCoordinate(row: 2, col: 1),
        getSwipeBehaviors: (_, _, _, _) => [],
      );

      expect(decision.type, equals(SwipeResult.match));
      expect(decision.matches.any((g) => g.emoji == Emojis.fire), isTrue);
    });

    test('Should prioritize Special Behaviors over normal matches', () {
      final grid = createTestGrid();
      grid[0][0].emoji = Emojis.fire;
      grid[0][1].emoji = Emojis.fire;
      grid[0][2].emoji = Emojis.rock;
      grid[1][2].emoji = Emojis.fire;

      final decision = SwipeDetector.evaluate(
        grid: grid,
        dCoord: TileCoordinate(row: 0, col: 2),
        tCoord: TileCoordinate(row: 1, col: 2),
        getSwipeBehaviors: (tile, r, c, emoji) {
          return [const BehaviorAction(type: ActionType.doNothing, x: 0, y: 0)];
        },
      );

      expect(decision.type, equals(SwipeResult.specialBehavior), 
        reason: 'Behaviors should intercept the evaluation before matches are checked');
      expect(decision.actions, isNotEmpty);
      expect(decision.matches, isEmpty);
    });

    test('The grid MUST be in its original state after evaluation ', () {
      final grid = createTestGrid();
      grid[0][0].emoji = Emojis.fire;
      grid[0][1].emoji = Emojis.rock;

      SwipeDetector.evaluate(
        grid: grid,
        dCoord: TileCoordinate(row: 0, col: 0),
        tCoord: TileCoordinate(row: 0, col: 1),
        getSwipeBehaviors: (_, _, _, _) => [],
      );

      expect(grid[0][0].emoji, equals(Emojis.fire), reason: 'Tile should be back to original after evaluation');
      expect(grid[0][1].emoji, equals(Emojis.rock), reason: 'Tile should be back to original after evaluation');
    });
  });
}