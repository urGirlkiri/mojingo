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
  final Map<GameEmoji, GameEmoji> Function(ReactionType) getReactions;
  
  final Logger _log = Logger('AlchemyEngine');

  AlchemyEngine({
    required this.gridManager,
    required this.getRecipe,     
    required this.getReactions,
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
      Recipe? recipe = getRecipe(emoji);

      if (recipe != null &&
          recipe.type == RecipeType.merge &&
          recipe.yields != null) {
        _executeMerge(recipe, coords, state, tilesToDestroy, mergePoint);
      } else if (recipe != null && recipe.type == RecipeType.volatile) {
        _executClear(coords, tilesToDestroy, transmutedTiles, recipe.blastType);
      } else {
        tilesToDestroy.addAll(coords);
      }
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

    targetTile.emoji = recipe.yields!;
    targetTile.reset();

    if (recipe.yields == gridManager.level.targetEmoji) {
      state.resolveEmoji(recipe.yields!, 1);
      targetTile.isFlying = true;
    }

    tilesToDestroy.addAll(coords.where((c) => c != spawnPoint));
  }

  void _executClear(
    Set<TileCoordinate> coords,
    Set<TileCoordinate> tilesToDestroy,
    Set<TileCoordinate> transmutedTiles,
    ReactionType? blastType,
  ) {
    final reactionType = blastType ?? ReactionType.explosive;
    _log.info('$reactionType DETONATED!');
    tilesToDestroy.addAll(coords);

    final reactions = getReactions(reactionType);

    for (var centerCoord in coords) {
      for (int r = centerCoord.row - 1; r <= centerCoord.row + 1; r++) {
        for (int c = centerCoord.col - 1; c <= centerCoord.col + 1; c++) {
          if (r >= 0 && r < GridManager.rows && c >= 0 && c < GridManager.cols) {
            Tile targetTile = gridManager.gridTiles[r][c];
            TileCoordinate targetCoord = TileCoordinate(row: r, col: c);

            GameEmoji? resultingEmoji = reactions[targetTile.emoji];

            if (resultingEmoji != null) {
              targetTile.emoji = resultingEmoji;
              targetTile.reset();
              transmutedTiles.add(targetCoord);
            } else if (!coords.contains(targetCoord)) {
              tilesToDestroy.add(targetCoord);
            }
          }
        }
      }
    }
  }
}