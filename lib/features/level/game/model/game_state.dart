import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:grimoji/config/constants.dart';
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
  bool isShuffling = false; 

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

    List<MatchGroup> matchGroups = await _attemptSwap(draggedCoordinate, targetCoordinate);

    if (matchGroups.isEmpty) {
      isProcessing = false;
      if (!_isDisposed) notifyListeners();
      return;
    }

    bool isFirstMatch = true;

    while (matchGroups.isNotEmpty) {
      _log.info('Processing ${matchGroups.length} groups...');

      _categorizeAnimations(matchGroups, isFirstMatch, targetCoordinate);
      notifyListeners();
      await Future.delayed(clearAnimationTime);
      if (_isDisposed) return;

      final Set<TileCoordinate> allMatchedCoords = matchGroups.expand((g) => g.coordinates).toSet();
      gameController.spawnTiles(allMatchedCoords, this, mergePoint: isFirstMatch ? targetCoordinate : null);
      
      await Future.delayed(const Duration(milliseconds: 100));
      if (_isDisposed) return;

      bool collected = gameController.collectFlyingTiles();
      if (collected) {
        notifyListeners(); 
      }
      gameController.triggerInitialFall();
      notifyListeners();

      await Future.delayed(gravityAnimationTime);
      if (_isDisposed) return;

      matchGroups = MatchDetector.findMatchGroups(gameController.grid);
      isFirstMatch = false;
    }

    if (!gameController.hasPossibleMoves()) {
      _log.info('NO MOVES LEFT!  Shuffling...');
      shuffleBoard();
    }

    bool isGameOver = onComboFinished();
    if (!isGameOver) hasTargetCombo = false;

    isProcessing = false;
    if (!_isDisposed) notifyListeners();
  }

  double shuffleProgress = 1.0; 

  Future<void> shuffleBoard() async {
    _log.info('Shuffling Board...');

    shuffleProgress = 0.0;
    notifyListeners();
    
    await Future.delayed(const Duration(milliseconds: 600)); 

    bool validBoard = false;
    while (!validBoard) {
      List<GameEmoji> allEmojis = gameController.grid
          .expand((row) => row.map((tile) => tile.emoji))
          .toList();
      allEmojis.shuffle();

      int index = 0;
      for (int r = 0; r < gameController.getRowCount(); r++) {
        for (int c = 0; c < gameController.getColCount(); c++) {
          gameController.grid[r][c].emoji = allEmojis[index++];
          gameController.grid[r][c].reset(); 
        }
      }

      validBoard = gameController.hasPossibleMoves();
      if (MatchDetector.findMatchGroups(gameController.grid).isNotEmpty) {
        validBoard = false; 
      }
    }

    shuffleProgress = 1.0;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 600)); 
  }
  Future<List<MatchGroup>> _attemptSwap(TileCoordinate dCoord, TileCoordinate tCoord) async {
    final originalD = TileCoordinate(row: dCoord.row, col: dCoord.col);
    final originalT = TileCoordinate(row: tCoord.row, col: tCoord.col);

    gameController.swapTiles(originalD, originalT);
    notifyListeners();
    await Future.delayed(swapAnimationTime);
    if (_isDisposed) return [];

    List<MatchGroup> matchGroups = MatchDetector.findMatchGroups(gameController.grid);

    if (matchGroups.isEmpty) {
      _log.info('Invalid Move! Reverting swap.');
      gameController.swapTiles(originalT, originalD);
      notifyListeners();
      await Future.delayed(swapAnimationTime);
      return [];
    }

    return matchGroups;
  }

  void _categorizeAnimations(List<MatchGroup> matchGroups, bool isFirstMatch, TileCoordinate targetCoord) {
    for (var group in matchGroups) {
      final recipe = RecipeBook.getRecipeFor(group.emoji);

      if (recipe != null && recipe.type == RecipeType.merge) {
        TileCoordinate catalyst = (isFirstMatch && group.coordinates.contains(targetCoord))
            ? targetCoord
            : group.coordinates.first;

        for (var coord in group.coordinates) {
          final tile = gameController.grid[coord.row][coord.col];
          coord == catalyst ? tile.isMerging = true : tile.isExploding = true;
        }
      } else {
        for (var coord in group.coordinates) {
          gameController.grid[coord.row][coord.col].isExploding = true;
        }
      }
    }
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