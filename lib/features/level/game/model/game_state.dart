import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:grimoji/config/board.dart';
import 'package:grimoji/config/emojis.dart';
import 'package:grimoji/config/levels.dart';
import 'package:grimoji/features/level/game/controller.dart';
import 'package:grimoji/features/level/game/model/alchemy/book.dart';
import 'package:grimoji/features/level/game/model/coordinate.dart';
import 'package:grimoji/features/level/game/model/match_detector.dart';
import 'package:logging/logging.dart';

class GameState extends ChangeNotifier {
  final GameLevel level;
  final void Function(GameEmoji, int) onEmojiDestroyed;
  final bool Function() onComboFinished;

  late final GameController gameController;
  final Logger _log = Logger('GameState');

  bool isProcessing = false;
  bool hasTargetCombo = false;
  bool _isDisposed = false;

  GameState({
    required this.level,
    required this.onEmojiDestroyed,
    required this.onComboFinished,
  }) {
    gameController = GameController(level);
    gameController.initialize();
  }

  void startInitialDrop() {
    _log.info('Starting to drop emojis');
    gameController.triggerInitialFall();
    notifyListeners();
  }

Future<void> resolveSwipe(
    TileCoordinate draggedCoordinate,
    TileCoordinate targetCoordinate,
  ) async {
    isProcessing = true;
    notifyListeners();

    final TileCoordinate originalD = TileCoordinate(
      row: draggedCoordinate.row,
      col: draggedCoordinate.col,
    );
    final TileCoordinate originalT = TileCoordinate(
      row: targetCoordinate.row,
      col: targetCoordinate.col,
    );

    gameController.swapTiles(originalD, originalT);
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 300));
    if (_isDisposed) return;

    List<MatchGroup> matchGroups = MatchDetector.findMatchGroups(
      gameController.grid,
    );

    if (matchGroups.isEmpty) {
      _log.info('Invalid Move! Reverting swap.');
      gameController.swapTiles(originalT, originalD);
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 300));

      isProcessing = false;
      notifyListeners();
      return;
    }

    bool hasCombos = true;
    bool isFirstMatch = true;

    while (hasCombos) {
      _log.info('Processing ${matchGroups.length} groups...');

      for (var group in matchGroups) {
        final recipe = RecipeBook.getRecipeFor(group.emoji);

        if (recipe != null && recipe.type == RecipeType.merge) {
          TileCoordinate catalyst =
              (isFirstMatch && group.coordinates.contains(targetCoordinate))
                  ? targetCoordinate
                  : group.coordinates.first;

          for (var coord in group.coordinates) {
            final tile = gameController.grid[coord.row][coord.col];
            if (coord == catalyst) {
              tile.isMerging = true;
            } else {
              tile.isExploding = true;
            }
          }
        } else {
          for (var coord in group.coordinates) {
            gameController.grid[coord.row][coord.col].isExploding = true;
          }
        }
      }

      notifyListeners();
      await Future.delayed(clearAnimationTime);
      if (_isDisposed) return;

      final Set<TileCoordinate> allMatchedCoords = 
          matchGroups.expand((g) => g.coordinates).toSet();

      gameController.spawnTiles(
        allMatchedCoords,
        this,
        mergePoint: isFirstMatch ? targetCoordinate : null,
      );
      notifyListeners();

      gameController.triggerInitialFall();
      notifyListeners();

      await Future.delayed(const Duration(milliseconds: 800));
      if (_isDisposed) return;

      matchGroups = MatchDetector.findMatchGroups(gameController.grid);
      if (matchGroups.isEmpty) {
        hasCombos = false;
      } else {
        isFirstMatch = false;
      }
    }

    bool isGameOver = onComboFinished();

    if (!isGameOver) {
      hasTargetCombo = false;
    }

    isProcessing = false;
    if (_isDisposed) return;

    notifyListeners();
  }
  void resolveEmoji(GameEmoji emoji, int count) {
    if (emoji == level.targetEmoji) {
      hasTargetCombo = true;
    }
    onEmojiDestroyed(emoji, count);
    notifyListeners();
  }

  
  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}