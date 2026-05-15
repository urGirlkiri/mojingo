import 'package:flutter_test/flutter_test.dart';
import 'package:grimoji/config/emojis.dart';
import 'package:grimoji/features/game/model/coordinate.dart';
import 'package:grimoji/features/game/model/tile.dart';
import 'package:grimoji/features/game/model/match_detector.dart';

void main() {
  group('MatchDetector  Tests', () {
    
    List<Tile> buildRow(int rowIdx, List<GameEmoji> emojis) {
      return List.generate(emojis.length, (colIdx) => 
        Tile(
          coordinate: TileCoordinate(row: rowIdx, col: colIdx), 
          emoji: emojis[colIdx]
        )
      );
    }

    group('Testing _scanGrid', () {
      
      test('Should detect matches ending at the rim', () {
        final grid = [
          buildRow(0, [Emojis.rock, Emojis.fire, Emojis.fire, Emojis.fire]), 
        ];
        final matches = MatchDetector.findMatchGroups(grid);
        expect(matches.length, 1);
        expect(matches.first.coordinates.length, 3);
      });

      test('Should detect matches just before the rim when the streak resets on the right', () {
        final grid = [
          buildRow(0, [Emojis.fire, Emojis.fire, Emojis.fire, Emojis.rock]), 
        ];
        final matches = MatchDetector.findMatchGroups(grid);
        expect(matches.length, 1);
      });

      test('Should detect matches just before the rim when the streak resets on the left', () {
        final grid = [
          buildRow(0, [Emojis.rock, Emojis.fire, Emojis.fire, Emojis.fire]), 
        ];
        final matches = MatchDetector.findMatchGroups(grid);
        expect(matches.length, 1);
      });

      test('Should detect distinct matches in the exact same row when streak resets to 1 and properly catch the second match group', () {
        final grid = [
          buildRow(0, [Emojis.fire, Emojis.fire, Emojis.fire, Emojis.rock, Emojis.droplet, Emojis.droplet, Emojis.droplet]), 
        ];
        final matches = MatchDetector.findMatchGroups(grid);
        expect(matches.length, 2);
        expect(matches[0].emoji, Emojis.fire);
        expect(matches[1].emoji, Emojis.droplet);
      });

      test('Should detect vertical match ending exactly at the bottom boundary', () {
        final grid = [
          buildRow(0, [Emojis.rock]),
          buildRow(1, [Emojis.fire]),
          buildRow(2, [Emojis.fire]),
          buildRow(3, [Emojis.fire]), 
        ];
        final matches = MatchDetector.findMatchGroups(grid);
        expect(matches.length, 1);
        expect(matches.first.coordinates.length, 3);
      });

      test('Should detect vertical match ending before the top boundary', () {
        final grid = [
          buildRow(3, [Emojis.rock]), 
          buildRow(0, [Emojis.fire]),
          buildRow(1, [Emojis.fire]),
          buildRow(2, [Emojis.fire]),
        ];
        final matches = MatchDetector.findMatchGroups(grid);
        expect(matches.length, 1);
      });

      test('Should ensure outer and inner limits do not throw range errors on non-square grids', () {
        final grid = [
          buildRow(0, [Emojis.fire, Emojis.fire, Emojis.fire, Emojis.rock]),
          buildRow(1, [Emojis.droplet, Emojis.rock, Emojis.bug, Emojis.alien]),
        ];
        expect(() => MatchDetector.findMatchGroups(grid), returnsNormally);
        final matches = MatchDetector.findMatchGroups(grid);
        expect(matches.length, 1);
      });
    });

    group('Testing _hasMatchInDirection', () {
      
      late List<List<Tile>> directionalGrid;

      setUp(() {
        directionalGrid = [
          buildRow(0, [Emojis.rock, Emojis.fire, Emojis.fire, Emojis.fire, Emojis.rock]),
          buildRow(1, [Emojis.rock, Emojis.fire, Emojis.rock, Emojis.rock, Emojis.rock]),
          buildRow(2, [Emojis.droplet, Emojis.fire, Emojis.rock, Emojis.rock, Emojis.droplet]), 
        ];
      });

      test('Should return true when checking the left edge of a horizontal match', () {
        expect(MatchDetector.hasMatchAt(directionalGrid, 0, 1), isTrue);
      });

      test('Should return true when checking the exact middle of a horizontal match', () {
        expect(MatchDetector.hasMatchAt(directionalGrid, 0, 2), isTrue);
      });

      test('Should return true when checking the right edge of a horizontal match', () {
        expect(MatchDetector.hasMatchAt(directionalGrid, 0, 3), isTrue);
      });

      test('Should return true when checking the top edge of a vertical match', () {
        expect(MatchDetector.hasMatchAt(directionalGrid, 0, 1), isTrue);
      });

      test('Should return true when checking the bottom edge of a vertical match', () {
        expect(MatchDetector.hasMatchAt(directionalGrid, 2, 1), isTrue);
      });

      test('Should return false when a streak is exactly two emojis long', () {
        final grid = [
          buildRow(0, [Emojis.rock, Emojis.fire, Emojis.fire, Emojis.rock]),
        ];
        expect(MatchDetector.hasMatchAt(grid, 0, 1), isFalse);
        expect(MatchDetector.hasMatchAt(grid, 0, 2), isFalse);
      });

      test('Should not throw range errors when checking the top left corner boundary', () {
        expect(() => MatchDetector.hasMatchAt(directionalGrid, 0, 0), returnsNormally);
        expect(MatchDetector.hasMatchAt(directionalGrid, 0, 0), isFalse);
      });

      test('Should not throw range errors when checking the bottom right corner boundary', () {
        expect(() => MatchDetector.hasMatchAt(directionalGrid, 2, 4), returnsNormally);
        expect(MatchDetector.hasMatchAt(directionalGrid, 2, 4), isFalse); 
      });
    });

    group('Testing large match detection', () {
      test('Should correctly group a 4-in-a-row match', () {
        final grid = [
          buildRow(0, [Emojis.droplet, Emojis.droplet, Emojis.droplet, Emojis.droplet]),
        ];
        final matches = MatchDetector.findMatchGroups(grid);
        expect(matches.length, 1);
        expect(matches.first.coordinates.length, 4);
      });

      test('Should correctly group a 5-in-a-column match', () {
        final grid = [
          buildRow(0, [Emojis.droplet]),
          buildRow(1, [Emojis.droplet]),
          buildRow(2, [Emojis.droplet]),
          buildRow(3, [Emojis.droplet]),
          buildRow(4, [Emojis.droplet]),
        ];
        final matches = MatchDetector.findMatchGroups(grid);
        expect(matches.length, 1);
        expect(matches.first.coordinates.length, 5);
      });

      test('Should correctly group a 6-in-a-row match', () {
        final grid = [
          buildRow(0, [Emojis.leafyGreen, Emojis.leafyGreen, Emojis.leafyGreen, Emojis.leafyGreen, Emojis.leafyGreen, Emojis.leafyGreen]),
        ];
        final matches = MatchDetector.findMatchGroups(grid);
        expect(matches.length, 1);
        expect(matches.first.coordinates.length, 6);
      });

      test('Should correctly group a 7-in-a-row match', () {
        final grid = [
          buildRow(0, [Emojis.leafyGreen, Emojis.leafyGreen, Emojis.leafyGreen, Emojis.leafyGreen, Emojis.leafyGreen, Emojis.leafyGreen, Emojis.leafyGreen]),
        ];
        final matches = MatchDetector.findMatchGroups(grid);
        expect(matches.length, 1);
        expect(matches.first.coordinates.length, 7);
      });
    });
  });
}