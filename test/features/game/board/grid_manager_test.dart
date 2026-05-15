import 'package:flutter_test/flutter_test.dart';
import 'package:grimoji/config/emojis.dart';
import 'package:grimoji/config/levels.dart';
import 'package:grimoji/features/game/board/manager.dart';
import 'package:grimoji/features/game/model/coordinate.dart';
import 'package:grimoji/features/game/model/match_detector.dart';

void main() {
  group('GridManager Tests', () {
    late GridManager gridManager;
    late GameLevel testLevel;

    setUp(() {
      testLevel = const GameLevel(
        number: 1,
        timeLimit: 60,
        targetEmoji: Emojis.ocean,
        targetAmount: 1,
        availableEmojis: [Emojis.droplet, Emojis.fire, Emojis.rock],
      );
      gridManager = GridManager(testLevel);
      gridManager.initialize();
    });

    test('Should initialize an 8x5 board with NO immediate matches', () {
      expect(gridManager.gridTiles.length, 8);
      final initialMatches = MatchDetector.findMatchGroups(gridManager.gridTiles);
      expect(initialMatches.isEmpty, isTrue);
    });

    test('swapTiles should swap positions in the array AND update internal tile coordinates', () {
      final tileA = gridManager.gridTiles[0][0];
      final tileB = gridManager.gridTiles[0][1];
      
      final originalEmojiA = tileA.emoji;
      final originalEmojiB = tileB.emoji;

      gridManager.swapTiles(TileCoordinate(row: 0, col: 0), TileCoordinate(row: 0, col: 1));

      expect(gridManager.gridTiles[0][0].emoji, originalEmojiB, reason: 'Tile A should now be in Tile B\'s original position');
      expect(gridManager.gridTiles[0][1].emoji, originalEmojiA, reason: 'Tile B should now be in Tile A\'s original position');

      expect(gridManager.gridTiles[0][0].coordinate.col, 0, reason: 'Tile A\'s internal coordinate should update to its new position');
      expect(gridManager.gridTiles[0][1].coordinate.col, 1, reason: 'Tile B\'s internal coordinate should update to its new position');
    });

    test('applyGravity should pull tiles down and spawn new ones at the top', () {
      final tileAbove = gridManager.gridTiles[6][0].emoji;

      final tilesToDestroy = {TileCoordinate(row: 7, col: 0)};

      gridManager.applyGravity(tilesToDestroy);

      expect(gridManager.gridTiles[7][0].emoji, tileAbove, reason: 'Gravity failed to pull the tile down');

      expect(testLevel.availableEmojis.contains(gridManager.gridTiles[0][0].emoji), isTrue, reason: 'A new tile should have spawned at the top with a valid emoji');
    });

    test('triggerInitialFall should reset all row coordinates to their final landing spots', () {
      gridManager.gridTiles[3][3].coordinate.row = -5;

      gridManager.triggerInitialFall();

      expect(gridManager.gridTiles[3][3].coordinate.row, 3, reason: 'coordinate.row should snap back to its actual row after falling');
    });

    group('Adjacency Finders', () {
      test('findAdjacentFilledTile should find a neighbor', () {
      final neighbor = gridManager.findAdjacentFilledTile(4, 2);
        
      expect(neighbor, isNotNull);
        final dx = (neighbor!.x - 4).abs();
        final dy = (neighbor.y - 2).abs();
        expect(dx + dy, 1, reason: 'Neighbor must be exactly 1 step away (no diagonals)');
      });

      test('findAdjacentEmptyTile should return null on a full board', () {
        final emptySpace = gridManager.findAdjacentEmptyTile(4, 2);
        
        expect(emptySpace, isNull);
      });

      test('findAdjacentEmptyTile should return a coordinate when an empty tile exists', () {
        const emptyEmoji = GameEmoji('svg/empty.svg', 'lottie/empty.json', '');
        
        gridManager.gridTiles[4][3].emoji = emptyEmoji;

        final emptySpace = gridManager.findAdjacentEmptyTile(4, 2);
        
        expect(emptySpace, isNotNull, reason: 'Should find the empty tile we just placed');
        expect(emptySpace!.x, equals(4));
        expect(emptySpace.y, equals(3));
      });
    });

    group('Flying Tiles', () {
      
      test('collectFlyingTiles should return false if nothing is flying', () {
        final result = gridManager.collectFlyingTiles();
        expect(result, isFalse, reason: 'Should return false when no tiles are isFlying');
      });

      test('collectFlyingTiles should return true and trigger gravity when tiles are flying', () {
        gridManager.gridTiles[7][2].isFlying = true;
        final tileAbove = gridManager.gridTiles[6][2].emoji;

        final result = gridManager.collectFlyingTiles();
        
        expect(result, isTrue, reason: 'Should return true because it found a flying tile');
        expect(gridManager.gridTiles[7][2].isFlying, isFalse, reason: 'Tile should no longer be flying after collection');
        expect(gridManager.gridTiles[7][2].emoji, equals(tileAbove), reason: 'Gravity should have pulled the tile above down into the empty space');
      });
    });

  });
}