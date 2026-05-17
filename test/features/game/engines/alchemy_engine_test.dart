import 'package:flutter_test/flutter_test.dart';
import 'package:grimoji/config/emojis.dart';
import 'package:grimoji/config/levels.dart';
import 'package:grimoji/features/alchemy/recipe_book.dart';
import 'package:grimoji/features/alchemy/recipes/recipe.dart';
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
        availableEmojis: [
          Emojis.droplet,
          Emojis.ocean,
          Emojis.cloud,
          Emojis.bomb,
          Emojis.rock,
          Emojis.volcano,
        ],
        type: LevelType.puzzle,
      );

      gridManager = GridManager(testLevel);
      gridManager.initialize();

      RecipeBook.initialize();

      alchemyEngine = AlchemyEngine(
        gridManager: gridManager,
        getRecipe: RecipeBook.getRecipeFor,
        getReactionFor: RecipeBook.getReactionFor,
        getTransformationsForType: RecipeBook.getTransformationsForType,
        getAoERadiusForType: RecipeBook.getAoERadiusForType,
      );

      mockState = MockGameState();
    });

    test(
      'Should merge 3 Droplets into 1 Ocean and mark it as Flying (Target)',
      () {
        gridManager.gridTiles[0][0].emoji = Emojis.droplet;
        gridManager.gridTiles[0][1].emoji = Emojis.droplet;
        gridManager.gridTiles[0][2].emoji = Emojis.droplet;

        final matchCoords = {
          TileCoordinate(row: 0, col: 0),
          TileCoordinate(row: 0, col: 1),
          TileCoordinate(row: 0, col: 2),
        };

        alchemyEngine.processMatches(
          matchCoords,
          mockState,
          mergePoint: TileCoordinate(row: 0, col: 1),
        );

        expect(gridManager.gridTiles[0][1].emoji, equals(Emojis.ocean));
        expect(gridManager.gridTiles[0][1].isFlying, isTrue);
      },
    );

    test('Should execute a Transmutation Explosion in a 3x3 radius', () {
      for (int r = 0; r < GridManager.rows; r++) {
        for (int c = 0; c < GridManager.cols; c++) {
          gridManager.gridTiles[r][c].emoji = Emojis.rock;
        }
      }

      gridManager.gridTiles[1][1].emoji = Emojis.bomb;

      alchemyEngine.processMatches({TileCoordinate(row: 1, col: 1)}, mockState);

      expect(
        gridManager.gridTiles[1][1].isTriggered,
        isTrue,
        reason: 'The bomb should be primed (isTriggered) for detonation',
      );

      expect(
        gridManager.gridTiles[3][3].emoji,
        equals(Emojis.rock),
        reason: 'Tiles outside the blast radius should be unharmed',
      );
    });

    test(
      'Should Transmute an Ocean into Salt when bomb detonates via executeBlastRadius',
      () {
        for (int r = 0; r < GridManager.rows; r++) {
          for (int c = 0; c < GridManager.cols; c++) {
            gridManager.gridTiles[r][c].emoji = Emojis.rock;
          }
        }

        gridManager.gridTiles[3][2].emoji = Emojis.bomb;
        gridManager.gridTiles[3][3].emoji = Emojis.ocean;

        gridManager.triggerInitialFall();

        alchemyEngine.processMatches({
          TileCoordinate(row: 3, col: 2),
        }, mockState);

        expect(
          gridManager.gridTiles[3][2].isTriggered,
          isTrue,
          reason: 'The bomb should be primed (isTriggered) for detonation',
        );

        Set<TileCoordinate> destroyed = gridManager.executeBlastRadius(
          TileCoordinate(row: 3, col: 2),
          radius: 1,
        );

        expect(
          destroyed.contains(TileCoordinate(row: 3, col: 3)),
          isFalse,
          reason: 'Ocean should NOT be in destroyed set - it transforms to salt',
        );

        expect(
          gridManager.gridTiles[3][3].isTransmuting,
          isTrue,
          reason: 'Ocean should be marked as transmuting',
        );

        expect(
          gridManager.gridTiles[3][3].isExploding,
          isFalse,
          reason: 'Ocean should NOT be marked as exploding',
        );

        expect(
          gridManager.gridTiles[3][3].emoji,
          equals(Emojis.salt),
          reason: 'Ocean should transform into salt',
        );
      },
    );

    test(
      'Should destroy tiles normally when no recipe exists, Basic Match-3',
      () {
        gridManager.gridTiles[0][0].emoji = Emojis.rock;
        gridManager.gridTiles[0][1].emoji = Emojis.rock;
        gridManager.gridTiles[0][2].emoji = Emojis.rock;

        final matchCoords = {
          TileCoordinate(row: 0, col: 0),
          TileCoordinate(row: 0, col: 1),
          TileCoordinate(row: 0, col: 2),
        };

        alchemyEngine.processMatches(matchCoords, mockState);

        expect(
          gridManager.gridTiles[0][0].emoji,
          anyOf([
            equals(Emojis.rock),
            equals(Emojis.droplet),
            equals(Emojis.ocean),
            equals(Emojis.cloud),
            equals(Emojis.bomb),
            equals(Emojis.volcano),
          ]),
          reason: 'Tile should have been processed',
        );
      },
    );

    test(
      'Should automatically find merge point when merge occurs in a falling combo',
      () {
        gridManager.gridTiles[0][0].emoji = Emojis.fire;
        gridManager.gridTiles[0][1].emoji = Emojis.fire;
        gridManager.gridTiles[0][2].emoji = Emojis.fire;
        gridManager.gridTiles[0][3].emoji = Emojis.fire;

        final matchCoords = {
          TileCoordinate(row: 0, col: 0),
          TileCoordinate(row: 0, col: 1),
          TileCoordinate(row: 0, col: 2),
          TileCoordinate(row: 0, col: 3),
        };

        alchemyEngine.processMatches(matchCoords, mockState, mergePoint: null);

        final expectedSpawn = matchCoords.first;
        expect(
          gridManager.gridTiles[expectedSpawn.row][expectedSpawn.col].emoji,
          equals(Emojis.bomb),
          reason:
              'Should merge into the first coordinate in the set when mergePoint is null',
        );
        expect(
          gridManager.gridTiles[expectedSpawn.row][expectedSpawn.col].isFlying,
          isFalse,
          reason: 'Bomb is not the target emoji, should not fly',
        );
      },
    );

    test('Should default to explosive ReactionType if no mapping exists', () {
      gridManager.gridTiles[1][1].emoji = Emojis.bomb;
      gridManager.gridTiles[1][2].emoji = Emojis.rock;

      alchemyEngine.processMatches({TileCoordinate(row: 1, col: 1)}, mockState);

      expect(
        gridManager.gridTiles[1][1].isTriggered,
        isTrue,
        reason: 'The bomb should be primed (isTriggered) for detonation',
      );
    });

    test('Should NOT merge when match size is less than requiredAmount', () {
      alchemyEngine = AlchemyEngine(
        gridManager: gridManager,
        getRecipe: (emoji) {
          if (emoji == Emojis.fire) {
            return const Recipe(
              ingredient: Emojis.fire,
              requiredAmount: 4,
              yields: Emojis.bomb,
            );
          }
          return null;
        },
        getReactionFor: (emoji) => null,
        getTransformationsForType: (type) => {},
        getAoERadiusForType: (type) => 1,
      );

      gridManager.gridTiles[0][0].emoji = Emojis.fire;
      gridManager.gridTiles[0][1].emoji = Emojis.fire;

      final matchCoords = {
        TileCoordinate(row: 0, col: 0),
        TileCoordinate(row: 0, col: 1),
      };

      final destroyedTiles = alchemyEngine.processMatches(matchCoords, mockState);

      expect(
        destroyedTiles,
        contains(TileCoordinate(row: 0, col: 0)),
        reason: 'Fire tiles should be marked for destruction',
      );
      expect(
        destroyedTiles,
        contains(TileCoordinate(row: 0, col: 1)),
        reason: 'Fire tiles should be marked for destruction',
      );
    });
  });

  group('AlchemyEngine Logic Tests (Chain Reactions & Crafting)', () {
    late GridManager gridManager;
    late AlchemyEngine alchemy;
    late MockGameState mockState;

    setUp(() {
      final testLevel = const GameLevel(
        number: 1,
        timeLimit: 60,
        targetEmoji: Emojis.ocean,
        targetAmount: 1,
        availableEmojis: [
          Emojis.droplet,
          Emojis.ocean,
          Emojis.cloud,
          Emojis.bomb,
          Emojis.rock,
          Emojis.volcano,
          Emojis.fire,
        ],
        type: LevelType.puzzle,
      );

      gridManager = GridManager(testLevel);
      gridManager.initialize();

      RecipeBook.initialize();

      alchemy = AlchemyEngine(
        gridManager: gridManager,
        getRecipe: RecipeBook.getRecipeFor,
        getReactionFor: RecipeBook.getReactionFor,
        getTransformationsForType: RecipeBook.getTransformationsForType,
        getAoERadiusForType: RecipeBook.getAoERadiusForType,
      );

      mockState = MockGameState();
    });

    test('Matching 3 Explosives should PRIME them, not destroy them', () {
      gridManager.gridTiles[0][0].emoji = Emojis.bomb;
      gridManager.gridTiles[0][1].emoji = Emojis.bomb;
      gridManager.gridTiles[0][2].emoji = Emojis.bomb;

      Set<TileCoordinate> matches = {
        TileCoordinate(row: 0, col: 0),
        TileCoordinate(row: 0, col: 1),
        TileCoordinate(row: 0, col: 2),
      };

      alchemy.processMatches(matches, mockState);

      expect(
        gridManager.gridTiles[0][0].isTriggered,
        isTrue,
        reason: 'Bomb 1 should be primed',
      );
      expect(
        gridManager.gridTiles[0][1].isTriggered,
        isTrue,
        reason: 'Bomb 2 should be primed',
      );
      expect(
        gridManager.gridTiles[0][2].isTriggered,
        isTrue,
        reason: 'Bomb 3 should be primed',
      );

      expect(gridManager.gridTiles[0][0].isExploding, isFalse);
      expect(gridManager.gridTiles[0][1].isExploding, isFalse);
      expect(gridManager.gridTiles[0][2].isExploding, isFalse);
    });

    test('Crafting a Bomb (4 Fires) does NOT self-ignite the new Bomb', () {
      gridManager.gridTiles[0][0].emoji = Emojis.fire;
      gridManager.gridTiles[0][1].emoji = Emojis.fire;
      gridManager.gridTiles[0][2].emoji = Emojis.fire;
      gridManager.gridTiles[0][3].emoji = Emojis.fire;

      Set<TileCoordinate> matches = {
        TileCoordinate(row: 0, col: 0),
        TileCoordinate(row: 0, col: 1),
        TileCoordinate(row: 0, col: 2),
        TileCoordinate(row: 0, col: 3),
      };

      TileCoordinate mergePoint = TileCoordinate(row: 0, col: 1);

      alchemy.processMatches(matches, mockState, mergePoint: mergePoint);

      final craftedTile = gridManager.gridTiles[0][1];
      expect(
        craftedTile.emoji,
        equals(Emojis.bomb),
        reason: '4 Fires should craft a Bomb',
      );
      expect(
        craftedTile.isTriggered,
        isFalse,
        reason: 'The newly crafted Bomb MUST NOT self-ignite!',
      );
    });
  });

  group('GridManager Blast Radius Tests', () {
    late GridManager gridManager;
    late AlchemyEngine alchemy;
    late MockGameState mockState;

    setUp(() {
      final testLevel = const GameLevel(
        number: 1,
        timeLimit: 60,
        targetEmoji: Emojis.ocean,
        targetAmount: 1,
        availableEmojis: [
          Emojis.droplet,
          Emojis.ocean,
          Emojis.cloud,
          Emojis.bomb,
          Emojis.rock,
          Emojis.volcano,
        ],
        type: LevelType.puzzle,
      );

      gridManager = GridManager(testLevel);
      gridManager.initialize();
      RecipeBook.initialize();

      alchemy = AlchemyEngine(
        gridManager: gridManager,
        getRecipe: RecipeBook.getRecipeFor,
        getReactionFor: RecipeBook.getReactionFor,
        getTransformationsForType: RecipeBook.getTransformationsForType,
        getAoERadiusForType: RecipeBook.getAoERadiusForType,
      );

      mockState = MockGameState();
    });

    test('Blast radius destroys normal tiles but PRIMES caught explosives', () {
      gridManager.triggerInitialFall();

      TileCoordinate center = TileCoordinate(row: 4, col: 2);
      gridManager.gridTiles[4][2].emoji = Emojis.bomb;

      gridManager.gridTiles[4][3].emoji = Emojis.droplet;
      gridManager.gridTiles[4][4].emoji = Emojis.bomb;

      Set<TileCoordinate> destroyed = gridManager.executeBlastRadius(
        center,
        radius: 2,
      );

      expect(
        destroyed.contains(TileCoordinate(row: 4, col: 3)),
        isTrue,
        reason: 'Droplet should be in the destroyed set',
      );
      expect(
        gridManager.gridTiles[4][3].isExploding,
        isTrue,
        reason: 'Droplet should be marked for explosion',
      );

      expect(
        destroyed.contains(TileCoordinate(row: 4, col: 4)),
        isFalse,
        reason: 'Caught Bomb should NOT be in the destroyed set',
      );
      expect(
        gridManager.gridTiles[4][4].isTriggered,
        isTrue,
        reason: 'Caught Bomb should be ignited for the chain reaction!',
      );
    });

    test(
      'Blast radius correctly handles center tile (center bomb is destroyed, caught bombs are triggered)',
      () {
        gridManager.triggerInitialFall();

        TileCoordinate center = TileCoordinate(row: 4, col: 2);
        gridManager.gridTiles[4][2].emoji = Emojis.bomb;
        gridManager.gridTiles[4][3].emoji = Emojis.rock;

        Set<TileCoordinate> destroyed = gridManager.executeBlastRadius(
          center,
          radius: 1,
        );

        expect(
          gridManager.gridTiles[4][2].isTriggered,
          isFalse,
          reason:
              'Center bomb should not be triggered (it is destroyed instead)',
        );
        expect(
          destroyed.contains(center),
          isTrue,
          reason:
              'Center bomb SHOULD be in destroyed set so gravity removes it',
        );
        // Rock should transform to volcano when hit by explosive!
        expect(
          gridManager.gridTiles[4][3].emoji,
          equals(Emojis.volcano),
          reason: 'Adjacent rock should transform into volcano',
        );
        expect(
          gridManager.gridTiles[4][3].isTransmuting,
          isTrue,
          reason: 'Adjacent rock should be marked as transmuting',
        );
        expect(
          gridManager.gridTiles[4][3].isExploding,
          isFalse,
          reason: 'Adjacent rock should NOT be marked as exploding',
        );
      },
    );

    test('AoE blast from Elemental reaction ignites caught explosives', () {
      for (int r = 0; r < GridManager.rows; r++) {
        for (int c = 0; c < GridManager.cols; c++) {
          gridManager.gridTiles[r][c].emoji = Emojis.rock;
        }
      }

      gridManager.gridTiles[3][3].emoji = Emojis.rock;
      gridManager.gridTiles[3][4].emoji = Emojis.bomb;

      alchemy.processMatches({TileCoordinate(row: 3, col: 3)}, mockState);

      expect(
        gridManager.gridTiles[3][4].isTriggered,
        isTrue,
        reason: 'Caught bomb should be ignited by Elemental AoE blast',
      );
      expect(
        gridManager.gridTiles[3][4].isExploding,
        isFalse,
        reason: 'Caught bomb should NOT be marked for explosion',
      );
    });
  });
}
