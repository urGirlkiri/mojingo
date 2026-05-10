import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:grimoji/config/emojis.dart';
import 'package:grimoji/config/levels.dart';
import 'package:grimoji/features/level/game/controller.dart';
import 'package:grimoji/features/level/game/model/coordinate.dart';
import 'package:grimoji/features/level/game/model/match_detector.dart';
import 'package:logging/logging.dart';

class GameState extends ChangeNotifier {
  final GameLevel level;
  final void Function(GameEmoji, int) onEmojiDestroyed;
  final bool Function()onComboFinished;

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

    Set<TileCoordinate> matches = MatchDetector.findMatches(
      gameController.grid,
    );

    if (matches.isEmpty) {
      _log.info('Invalid Move! Reverting swap.');
      gameController.swapTiles(originalT, originalD);
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 300));
      if (_isDisposed) return;

      isProcessing = false;
      notifyListeners();
      return;
    }

    bool hasCombos = true;
    bool isFirstMatch = true;

    while (hasCombos) {
      _log.info('Found ${matches.length} matches! Triggering Avalanche...');

      gameController.spawnTiles(
        matches,
        this,
        mergePoint: isFirstMatch ? targetCoordinate : null,
      );

      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 50));
      if (_isDisposed) return;

      gameController.triggerInitialFall();
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 800));
      if (_isDisposed) return;

      matches = MatchDetector.findMatches(gameController.grid);
      if (matches.isEmpty) {
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
