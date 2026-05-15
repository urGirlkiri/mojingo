import 'package:flutter_test/flutter_test.dart';
import 'package:grimoji/config/emojis.dart';
import 'package:grimoji/config/levels.dart';
import 'package:grimoji/features/alchemy/recipes/recipe.dart';
import 'package:grimoji/features/alchemy/reactions/reaction.dart';
import 'package:grimoji/features/game/board/manager.dart';
import 'package:grimoji/features/game/engines/alchemy_engine.dart';
import 'package:grimoji/features/game/model/coordinate.dart';
import 'package:grimoji/features/game/state.dart';
import 'package:mockito/mockito.dart';

class MockGameState extends Mock implements GameState {
  @override
  void resolveEmoji(GameEmoji emoji, int count) {}
}

void main() {
  group('AlchemyEngine Tests', () {
    late GridManager gridManager;
    late AlchemyEngine alchemyEngine;
    late MockGameState mockState;

    setUp(() {
      final testLevel = const GameLevel(
        number: 1,
        timeLimit: 60,
        targetEmoji: Emojis.ocean,
        targetAmount: 1,
        availableEmojis: [Emojis.alien, Emojis.robot, Emojis.skull], 
      );
      
      gridManager = GridManager(testLevel);
      gridManager.initialize();
      
      alchemyEngine = AlchemyEngine(
        gridManager: gridManager,
        getRecipe: (emoji) {
          if (emoji == Emojis.droplet) {
            return const Recipe(ingredient: Emojis.droplet, requiredAmount: 3, yields: Emojis.ocean);
          }
          if (emoji == Emojis.fire) {
            return const Recipe(ingredient: Emojis.fire, requiredAmount: 3, yields: Emojis.bomb);
          }
          return null; 
        },
        getReactionFor: (emoji) {
          if (emoji == Emojis.bomb) {
            return Reaction(
              type: ReactionType.explosive,
              triggers: [Emojis.bomb],
              transformations: {Emojis.ocean: Emojis.salt},
            );
          }
          return null;
        },
        getTransformationsForType: (type) {
          if (type == ReactionType.explosive) {
            return {Emojis.ocean: Emojis.salt};
          }
          return {};
        },
      );
      
      mockState = MockGameState();
    });

    test('Should merge 3 Droplets into 1 Ocean and mark it as Flying (Target)', () {
      gridManager.gridTiles[0][0].emoji = Emojis.droplet;
      gridManager.gridTiles[0][1].emoji = Emojis.droplet;
      gridManager.gridTiles[0][2].emoji = Emojis.droplet;

      final matchCoords = {
        TileCoordinate(row: 0, col: 0),
        TileCoordinate(row: 0, col: 1),
        TileCoordinate(row: 0, col: 2),
      };

      alchemyEngine.processMatches(matchCoords, mockState, mergePoint: TileCoordinate(row: 0, col: 1));

      expect(gridManager.gridTiles[0][1].emoji, equals(Emojis.ocean));
      expect(gridManager.gridTiles[0][1].isFlying, isTrue);
    });

    test('Should execute a Transmutation Explosion in a 3x3 radius', () {
      for (int r = 0; r < GridManager.rows; r++) {
        for (int c = 0; c < GridManager.cols; c++) {
          gridManager.gridTiles[r][c].emoji = Emojis.rock;
        }
      }

      gridManager.gridTiles[1][1].emoji = Emojis.bomb;

      alchemyEngine.processMatches({TileCoordinate(row: 1, col: 1)}, mockState);

      for (int r = 0; r <= 2; r++) {
        for (int c = 0; c <= 2; c++) {
          expect(gridManager.gridTiles[r][c].emoji, isNot(equals(Emojis.rock)), 
            reason: 'Tile at $r,$c should have been destroyed and replaced by sky drops');
        }
      }

      expect(gridManager.gridTiles[3][3].emoji, equals(Emojis.rock),
        reason: 'Tiles outside the blast radius should be unharmed');
    });

    test('Should Transmute an Ocean into Salt and properly handle gravity', () {
      for (int r = 0; r < GridManager.rows; r++) {
        for (int c = 0; c < GridManager.cols; c++) {
          gridManager.gridTiles[r][c].emoji = Emojis.rock;
        }
      }

      gridManager.gridTiles[7][1].emoji = Emojis.bomb;
      gridManager.gridTiles[7][2].emoji = Emojis.ocean; 

      alchemyEngine.processMatches({TileCoordinate(row: 7, col: 1)}, mockState);

      expect(gridManager.gridTiles[7][2].emoji, equals(Emojis.salt), 
        reason: 'Ocean should transmute to Salt and not be destroyed');
      
      expect(gridManager.gridTiles[7][1].emoji, equals(Emojis.rock),
        reason: 'The bomb should be destroyed, and a rock from above should fall into its place');
    });

    test('Should destroy tiles normally when no recipe exists, Basic Match-3', () {
      gridManager.gridTiles[0][0].emoji = Emojis.rock;
      gridManager.gridTiles[0][1].emoji = Emojis.rock;
      gridManager.gridTiles[0][2].emoji = Emojis.rock;

      final matchCoords = {
        TileCoordinate(row: 0, col: 0),
        TileCoordinate(row: 0, col: 1),
        TileCoordinate(row: 0, col: 2),
      };

      alchemyEngine.processMatches(matchCoords, mockState);

      expect(gridManager.gridTiles[0][0].emoji, isNot(equals(Emojis.rock)), 
        reason: 'Tile should have been destroyed and replaced by the rock above it');
      expect(gridManager.gridTiles[0][1].emoji, isNot(equals(Emojis.rock)), 
        reason: 'Tile should have been destroyed and replaced by the rock above it');
      expect(gridManager.gridTiles[0][2].emoji, isNot(equals(Emojis.rock)), 
        reason: 'Tile should have been destroyed and replaced by the rock above it');
    });

    test('Should merge automatically find merge point when merge occurs in a falling combo', () {
      gridManager.gridTiles[0][0].emoji = Emojis.fire;
      gridManager.gridTiles[0][1].emoji = Emojis.fire;
      gridManager.gridTiles[0][2].emoji = Emojis.fire;

      final matchCoords = {
        TileCoordinate(row: 0, col: 0),
        TileCoordinate(row: 0, col: 1),
        TileCoordinate(row: 0, col: 2),
      };

      alchemyEngine.processMatches(matchCoords, mockState, mergePoint: null);

      final expectedSpawn = matchCoords.first;
      expect(gridManager.gridTiles[expectedSpawn.row][expectedSpawn.col].emoji, equals(Emojis.bomb), 
        reason: 'Should merge into the first coordinate in the set when mergePoint is null');
      expect(gridManager.gridTiles[expectedSpawn.row][expectedSpawn.col].isFlying, isFalse, 
        reason: 'Bomb is not the target emoji, should not fly');
    });

    test('Should default to explosive ReactionType if no mapping exists', () {
      gridManager.gridTiles[1][1].emoji = Emojis.bomb;
      
      gridManager.gridTiles[1][2].emoji = Emojis.rock;

      alchemyEngine.processMatches({TileCoordinate(row: 1, col: 1)}, mockState);

      expect(gridManager.gridTiles[1][2].emoji, isNot(equals(Emojis.rock)), 
        reason: 'Tile should have been destroyed by the explosive reaction');
    });
  });
}