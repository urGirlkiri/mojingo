import 'package:flutter_test/flutter_test.dart';
import 'package:grimoji/config/emojis.dart';
import 'package:grimoji/config/levels.dart';
import 'package:grimoji/features/game/board/manager.dart'; // Adjust path if needed
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
      expect(gridManager.gridTiles.length, 8, reason: 'Should have 8 rows');
      expect(gridManager.gridTiles[0].length, 5, reason: 'Should have 5 columns');

      final initialMatches = MatchDetector.findMatchGroups(gridManager.gridTiles);
      expect(initialMatches.isEmpty, isTrue, reason: '_getRandomSafeEmoji  should guarantee a clean board on start');

      final hasPossibleMoves = gridManager.hasPossibleMoves(); 
      expect(hasPossibleMoves, true, reason: 'A newly initialized board should always have possible moves');
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
        // Since the board just initialized, every tile is filled!
        final neighbor = gridManager.findAdjacentFilledTile(4, 2);
        
        expect(neighbor, isNotNull);
        // Ensure the neighbor is actually adjacent (math check)
        final dx = (neighbor!.x - 4).abs();
        final dy = (neighbor.y - 2).abs();
        expect(dx + dy, 1, reason: 'Neighbor must be exactly 1 step away (no diagonals)');
      });

      test('findAdjacentEmptyTile should return null on a full board', () {
        final emptySpace = gridManager.findAdjacentEmptyTile(4, 2);
        
        expect(emptySpace, isNull);
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

    group('Hints', () {
      test('getHintMove should find a valid swap that creates a match', () {
        final safeEmojis = [Emojis.rock, Emojis.droplet, Emojis.alien, Emojis.bug];
        for (int r = 0; r < GridManager.rows; r++) {
          for (int c = 0; c < GridManager.cols; c++) {
            int colorIndex = (r + c + (r % 2)) % safeEmojis.length;
            gridManager.gridTiles[r][c].emoji = safeEmojis[colorIndex];
          }
        }

        gridManager.gridTiles[0][0].emoji = Emojis.fire;
        gridManager.gridTiles[0][1].emoji = Emojis.fire;
        gridManager.gridTiles[0][2].emoji = Emojis.rock;
        gridManager.gridTiles[0][3].emoji = Emojis.fire;
        gridManager.gridTiles[0][4].emoji = Emojis.droplet;
        
        gridManager.gridTiles[1][2].emoji = Emojis.droplet;
        gridManager.gridTiles[2][2].emoji = Emojis.alien;

        final hint = gridManager.getHintMove();

        expect(hint, isNotNull, reason: 'Should find the seeded hint');
        expect(hint!.length, 2, reason: 'A hint must contain exactly 2 coordinates to swap');
        
        final containsRock = hint.any((coord) => coord.row == 0 && coord.col == 2);
        final containsThirdFire = hint.any((coord) => coord.row == 0 && coord.col == 3);
        
        expect(containsRock, isTrue, reason: 'Hint should tell us to move the Rock blocking the match');
        expect(containsThirdFire, isTrue, reason: 'Hint should tell us to move the Fire into place');
      });

      test('hasPossibleMoves should return false on a completely deadlocked board', () {
        final safeEmojis = [Emojis.rock, Emojis.droplet, Emojis.alien, Emojis.bug];
        
        for (int r = 0; r < GridManager.rows; r++) {
          for (int c = 0; c < GridManager.cols; c++) {
            int colorIndex = (r + c + (r % 2)) % safeEmojis.length;
            gridManager.gridTiles[r][c].emoji = safeEmojis[colorIndex];
          }
        }

        final canMove = gridManager.hasPossibleMoves();
        final hint = gridManager.getHintMove();

        expect(canMove, isFalse, reason: 'You can\'t make any moves on a deadlocked board');
        expect(hint, isNull, reason: 'Should not be able to provide a hint when there are no possible moves');
      });
    });
  });
}