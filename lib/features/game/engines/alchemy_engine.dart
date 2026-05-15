import 'package:grimoji/config/emojis.dart';
import 'package:grimoji/features/game/state.dart';
import 'package:grimoji/features/game/model/tile.dart';
import 'package:grimoji/features/game/model/coordinate.dart';
import 'package:grimoji/features/alchemy/recipes/recipe.dart';
import 'package:grimoji/features/alchemy/reactions/reaction.dart';
import 'package:logging/logging.dart';
import '../board/manager.dart';

class AlchemyEngine {
  final GridManager gridManager;
  
  final Recipe? Function(GameEmoji) getRecipe;
  final Reaction? Function(GameEmoji) getReactionFor;
  final Map<GameEmoji, GameEmoji> Function(ReactionType) getTransformationsForType;
  
  final Logger _log = Logger('AlchemyEngine');

  AlchemyEngine({
    required this.gridManager,
    required this.getRecipe,     
    required this.getReactionFor,
    required this.getTransformationsForType,
  });

  void processMatches(
    Set<TileCoordinate> matches,
    GameState state, {
    TileCoordinate? mergePoint,
  }) {
    Set<TileCoordinate> tilesToDestroy = {};
    Set<TileCoordinate> transmutedTiles = {};

    _processMatches(
      matches,
      state,
      tilesToDestroy,
      transmutedTiles,
      mergePoint,
    );

    tilesToDestroy.removeWhere((coord) => transmutedTiles.contains(coord));

    gridManager.applyGravity(tilesToDestroy);
  }

  void _processMatches(
    Set<TileCoordinate> matches,
    GameState state,
    Set<TileCoordinate> tilesToDestroy,
    Set<TileCoordinate> transmutedTiles,
    TileCoordinate? mergePoint,
  ) {
    Map<GameEmoji, Set<TileCoordinate>> groupedMatches = {};
    for (var match in matches) {
      GameEmoji emoji = gridManager.gridTiles[match.row][match.col].emoji;
      groupedMatches.putIfAbsent(emoji, () => {}).add(match);
    }

    groupedMatches.forEach((emoji, coords) {
      state.resolveEmoji(emoji, coords.length);

      final recipe = getRecipe(emoji);
      if (recipe != null) {
        _executeMerge(recipe, coords, state, tilesToDestroy, mergePoint);
        return;
      }

      final reaction = getReactionFor(emoji);
      if (reaction != null) {
        _executeReaction(coords, tilesToDestroy, transmutedTiles, reaction.type);
        return;
      }

      tilesToDestroy.addAll(coords);
    });
  }

  void _executeMerge(
    Recipe recipe,
    Set<TileCoordinate> coords,
    GameState state,
    Set<TileCoordinate> tilesToDestroy,
    TileCoordinate? mergePoint,
  ) {
    TileCoordinate spawnPoint = coords.contains(mergePoint)
        ? mergePoint!
        : coords.first;
    Tile targetTile = gridManager.gridTiles[spawnPoint.row][spawnPoint.col];

    targetTile.emoji = recipe.yields;
    targetTile.reset();

    if (recipe.yields == gridManager.level.targetEmoji) {
      state.resolveEmoji(recipe.yields, 1);
      targetTile.isFlying = true;
    }

    tilesToDestroy.addAll(coords.where((c) => c != spawnPoint));
  }

  /// Handles data-driven reaction of emojis in an area based on trigger emojis.
  void _executeReaction(
    Set<TileCoordinate> coords,
    Set<TileCoordinate> tilesToDestroy,
    Set<TileCoordinate> transmutedTiles,
    ReactionType type,
  ) {
    _log.info('Reaction Initiated: $type');
    
    // The trigger matches themselves are always destroyed
    tilesToDestroy.addAll(coords);

    // Get the transformations for this specific reaction type from our data book
    final transformations = getTransformationsForType(type);

    for (var centerCoord in coords) {
      // Check 3x3 area around the trigger/catalyst
      for (int r = centerCoord.row - 1; r <= centerCoord.row + 1; r++) {
        for (int c = centerCoord.col - 1; c <= centerCoord.col + 1; c++) {
          if (r >= 0 && r < GridManager.rows && c >= 0 && c < GridManager.cols) {
            Tile targetTile = gridManager.gridTiles[r][c];
            TileCoordinate targetCoord = TileCoordinate(row: r, col: c);

            // DATA-DRIVEN CHECK: Does this emoji have a specific reaction result?
            GameEmoji? resultingEmoji = transformations[targetTile.emoji];

            if (resultingEmoji != null) {
              // React the tile into the new form
              targetTile.emoji = resultingEmoji;
              targetTile.reset();
              transmutedTiles.add(targetCoord);
              _log.fine('Reacted ${targetTile.emoji.visual} at $targetCoord');
            } else if (!coords.contains(targetCoord)) {
              // Default behavior: if no transformation exists, the "blast" destroys the tile
              tilesToDestroy.add(targetCoord);
            }
          }
        }
      }
    }
  }
}