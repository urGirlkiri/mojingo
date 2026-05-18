import 'package:flutter_test/flutter_test.dart';
import 'package:grimoji/config/emojis.dart';
import 'package:grimoji/config/levels/game_level.dart';
import 'package:grimoji/config/levels/index.dart';
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
        type: LevelType.puzzle,
      );
      gridManager = GridManager(testLevel);
      gridManager.initialize();
    });

    test('Should initialize an 8x5 board with NO immediate matches', () {
      expect(gridManager.gridTiles.length, 8);
      final initialMatches = MatchDetector.findMatchedGroups(gridManager.gridTiles);
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

    group('Swap & Memory Tests', () {
      test('swapTiles correctly moves tiles and updates coordinates via copyWith', () {
        gridManager.gridTiles[0][0].emoji = Emojis.fire;
        gridManager.gridTiles[0][1].emoji = Emojis.droplet;

        final tileA = gridManager.gridTiles[0][0];
        final tileB = gridManager.gridTiles[0][1];

        final idA = tileA.id;
        final idB = tileB.id;
        final hashA = tileA.hashCode;
        final hashB = tileB.hashCode;

        gridManager.swapTiles(
          TileCoordinate(row: 0, col: 0),
          TileCoordinate(row: 0, col: 1),
        );

        final newTileA = gridManager.gridTiles[0][1];
        final newTileB = gridManager.gridTiles[0][0]; 

        expect(newTileA.emoji, Emojis.fire, reason: 'Tile A did not move to column 1');
        expect(newTileB.emoji, Emojis.droplet, reason: 'Tile B did not move to column 0');

        expect(newTileA.hashCode, isNot(equals(hashA)), reason: 'Tile A was mutated instead of copied!');
        expect(newTileB.hashCode, isNot(equals(hashB)), reason: 'Tile B was mutated instead of copied!');

        expect(newTileA.id, equals(idA), reason: 'Tile A lost its unique ID during copyWith');
        expect(newTileB.id, equals(idB), reason: 'Tile B lost its unique ID during copyWith');

        expect(newTileA.coordinate.row, 0);
        expect(newTileA.coordinate.col, 1);
        
        expect(newTileB.coordinate.row, 0);
        expect(newTileB.coordinate.col, 0);
      });
    });

  });
}