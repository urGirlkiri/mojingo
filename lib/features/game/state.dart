import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:grimoji/config/constants.dart';
import 'package:grimoji/config/emojis.dart';
import 'package:grimoji/config/levels.dart';
import 'package:grimoji/features/alchemy/recipes/recipe.dart';
import 'package:grimoji/features/game/controller.dart';
import 'package:grimoji/features/alchemy/recipe_book.dart';
import 'package:grimoji/features/game/model/coordinate.dart';
import 'package:grimoji/features/game/model/match_detector.dart';
import 'package:grimoji/features/game/model/tile.dart';
import 'package:logging/logging.dart';

class GameState extends ChangeNotifier {
  final void Function(GameEmoji, int) onEmojiDestroyed;
  final bool Function() onComboFinished;

  late final GameController gameController;
  final Logger _log = Logger('GameState');
  Timer? _idleTimer;

  bool isProcessing = false;
  bool hasTargetCombo = false;
  bool _isDisposed = false;
  bool isShuffling = false;

  List<TileCoordinate>? _currentHints;

  void _startIdleTimer() {
    _log.info('Idle timer started (Waiting 5 seconds)...');
    _idleTimer?.cancel();
    _idleTimer = Timer(const Duration(seconds: 5), _triggerHint);
  }

  void resetIdleTimer() {
    _log.info('Screen touched.. Resetting idle timer.');

    _clearHint();
    if (!isProcessing && !isShuffling) {
      _startIdleTimer();
    }
  }

  GameState({
    required GameLevel level,
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
    _startIdleTimer();
  }

  Future<void> resolveSwipe(
    TileCoordinate draggedCoordinate,
    TileCoordinate targetCoordinate,
  ) async {
    isProcessing = true;
    resetIdleTimer();
    notifyListeners();

    List<MatchGroup> matchGroups = await _attemptSwap(
      draggedCoordinate,
      targetCoordinate,
    );

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

      final Set<TileCoordinate> allMatchedCoords = matchGroups
          .expand((g) => g.coordinates)
          .toSet();
      gameController.spawnTiles(
        allMatchedCoords,
        this,
        mergePoint: isFirstMatch ? targetCoordinate : null,
      );

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

    _log.info('Processing After Turn Emoji Behaviors...');
    gameController.processTurnEndBehaviors();
    notifyListeners(); 

    await Future.delayed(const Duration(milliseconds: 300)); 
    if (_isDisposed) return;

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

  void _triggerHint() {
    if (isProcessing || isShuffling || _isDisposed) return;

    _currentHints = gameController.getHintMove();
    if (_currentHints != null) {
      Tile tileA =
          gameController.grid[_currentHints![0].row][_currentHints![0].col];
      Tile tileB =
          gameController.grid[_currentHints![1].row][_currentHints![1].col];

      tileA.isHinting = true;
      tileA.hintPartner = tileB.coordinate;

      tileB.isHinting = true;
      tileB.hintPartner = tileA.coordinate;

      notifyListeners();
    }
  }

  void _clearHint() {
    _idleTimer?.cancel();
    _currentHints = null;

    for (int r = 0; r < gameController.getRowCount(); r++) {
      for (int c = 0; c < gameController.getColCount(); c++) {
        gameController.grid[r][c].isHinting = false;
        gameController.grid[r][c].hintPartner = null;
      }
    }
    notifyListeners();
  }

  Future<List<MatchGroup>> _attemptSwap(
    TileCoordinate dCoord,
    TileCoordinate tCoord,
  ) async {
    final originalD = TileCoordinate(row: dCoord.row, col: dCoord.col);
    final originalT = TileCoordinate(row: tCoord.row, col: tCoord.col);

    final tileD = gameController.grid[originalD.row][originalD.col];
    final tileT = gameController.grid[originalT.row][originalT.col];

    gameController.swapTiles(originalD, originalT);
    notifyListeners();
    await Future.delayed(swapAnimationTime);
    if (_isDisposed) return [];

    final actionsD = gameController.processSwipedWithBehavior(
      tileT,
      originalD.row,
      originalD.col,
      tileD.emoji,
    );
    final actionsT = gameController.processSwipedWithBehavior(
      tileD,
      originalT.row,
      originalT.col,
      tileT.emoji,
    );

    if (actionsD.isNotEmpty || actionsT.isNotEmpty) {
      _log.info('Special swipe behavior triggered!');
      final allActions = [...actionsD, ...actionsT];
      gameController.executeBehaviorActions(allActions, originalD.row, originalD.col);
      return [];
    }

    List<MatchGroup> matchGroups = MatchDetector.findMatchGroups(
      gameController.grid,
    );

    if (matchGroups.isEmpty) {
      _log.info('Invalid Move! Reverting swap.');
      gameController.swapTiles(originalT, originalD);
      notifyListeners();
      await Future.delayed(swapAnimationTime);
      return [];
    }

    return matchGroups;
  }

  void _categorizeAnimations(
    List<MatchGroup> matchGroups,
    bool isFirstMatch,
    TileCoordinate targetCoord,
  ) {
    for (var group in matchGroups) {
      final recipe = RecipeBook.getRecipeFor(group.emoji);

      if (recipe != null && recipe.type == RecipeType.merge) {
        TileCoordinate catalyst =
            (isFirstMatch && group.coordinates.contains(targetCoord))
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
    if (emoji == gameController.level.targetEmoji) {
      hasTargetCombo = true;
    }
    onEmojiDestroyed(emoji, count);
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _idleTimer?.cancel();
    isProcessing = false;
    super.dispose();
  }
}
