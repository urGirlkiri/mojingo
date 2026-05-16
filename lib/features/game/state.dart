import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:grimoji/config/constants.dart';
import 'package:grimoji/config/emojis.dart';
import 'package:grimoji/config/levels.dart';
import 'package:grimoji/features/alchemy/recipe_book.dart';
import 'package:grimoji/features/game/controller.dart';
import 'package:grimoji/features/game/model/coordinate.dart';
import 'package:grimoji/features/game/model/match_detector.dart';
import 'package:grimoji/features/game/model/swipe_detector.dart';
import 'package:grimoji/features/game/model/tile.dart';
import 'package:logging/logging.dart';

class GameState extends ChangeNotifier {
  final void Function(GameEmoji, int) onEmojiDestroyed;
  final bool Function() onComboFinished;

  late final GameController gameController;
  final Logger _log = Logger('GameState');
  Timer? _hintTimer;

  bool isProcessing = false;
  bool hasTargetCombo = false;
  bool _isDisposed = false;
  bool isShuffling = false;
  bool _isGameOver = false;

  List<TileCoordinate>? _currentHints;

  void _startHintTimer() {
    _log.info('Hint timer started (Waiting 5 seconds)...');
    _hintTimer?.cancel();
    _hintTimer = Timer(const Duration(seconds: 5), _triggerHint);
  }

  void resetTimer() {
    if (_isDisposed) return;

    if (_isGameOver) {
      _log.info('Game Over - Timer disabled');
      _hintTimer?.cancel();
      return;
    }

    _log.info('Timer reset - clearing hints and restarting countdown');
    _clearHint();
    if (!isProcessing && !isShuffling) {
      _startHintTimer();
    }
    notifyListeners();
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
    resetTimer();
  }

  void setGameOver() {
    _log.info('Game Over - stopping timers and disabling interactions');
    _isGameOver = true;
    _hintTimer?.cancel();
    isProcessing = false;
    notifyListeners();
  }

  Future<void> resolveSwipe(
    TileCoordinate draggedCoordinate,
    TileCoordinate targetCoordinate,
  ) async {
    if (_isGameOver) {
      _log.info('Game Over - swipe ignored');
      return;
    }

    isProcessing = true;
    resetTimer();
    notifyListeners();

    List<MatchGroup> matchGroups = await _attemptSwap(
      draggedCoordinate,
      targetCoordinate,
    );

    if (matchGroups.isEmpty) {
      hasTargetCombo = false;

      isProcessing = false;
      if (!_isDisposed) {
        notifyListeners();
        resetTimer();
      }
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
      await shuffleBoard();
    }

    _log.info('Processing After Turn Emoji Behaviors...');
    gameController.processTurnEndBehaviors();
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 300));
    if (_isDisposed) return;

    hasTargetCombo = false;

    isProcessing = false;
    if (!_isDisposed) {
      notifyListeners();
      resetTimer();
      onComboFinished();
    }
  }

  double shuffleProgress = 1.0;

  Future<void> shuffleBoard() async {
    _log.info('Shuffling Board...');

    shuffleProgress = 0.0;
    isShuffling = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 600));

    gameController.shuffleGrid();

    shuffleProgress = 1.0;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 600));

    isShuffling = false;
    if (!_isDisposed) {
      _log.info('Shuffle complete - restarting hint timer');
      notifyListeners();
      resetTimer();
    }
  }

  void _triggerHint() {
    _log.info('Hint timer fired - checking for hint move');
    if (isProcessing || isShuffling || _isDisposed || _isGameOver) {
      _log.info(
        'Hint skipped - processing=$isProcessing, shuffling=$isShuffling, disposed=$_isDisposed, gameOver=$_isGameOver',
      );
      return;
    }

    _currentHints = gameController.getHintMove();
    if (_currentHints != null) {
      _log.info('Hint found at ${_currentHints![0]} and ${_currentHints![1]}');
      Tile tileA =
          gameController.grid[_currentHints![0].row][_currentHints![0].col];
      Tile tileB =
          gameController.grid[_currentHints![1].row][_currentHints![1].col];

      tileA.isHinting = true;
      tileA.hintPartner = tileB.coordinate;

      tileB.isHinting = true;
      tileB.hintPartner = tileA.coordinate;

      notifyListeners();
    } else {
      _log.info('No hint available - no valid moves found');
    }
  }

  void _clearHint() {
    _log.info('Clearing hints and canceling Hint timer');
    _hintTimer?.cancel();
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
    gameController.swapTiles(dCoord, tCoord);
    notifyListeners();
    
    final decision = gameController.evaluateSwipe(dCoord, tCoord);

    if (decision.type == SwipeResultType.invalid) {
      _log.info('Invalid swap - playing snap-back animation');

      await Future.delayed(swapAnimationTime);
      if (_isDisposed) return [];

      gameController.swapTiles(tCoord, dCoord);
      notifyListeners();

      if (!_isDisposed) {
        _log.info('Invalid swap complete - restarting hint timer');
        _clearHint();
        _startHintTimer();
      }
      return [];
    } else {
      if (_isDisposed) return [];

      if (decision.type == SwipeResultType.specialBehavior) {
        _log.info('Special swipe behavior triggered!');
        gameController.executeBehaviorActions(
          decision.actions,
          dCoord.row,
          dCoord.col,
        );
        return [];
      }

      return decision.matches;
    }
  }

  void _categorizeAnimations(
    List<MatchGroup> matchGroups,
    bool isFirstMatch,
    TileCoordinate targetCoord,
  ) {
    for (var group in matchGroups) {
      final recipe = RecipeBook.getRecipeFor(group.emoji);

      if (recipe != null) {
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
    _hintTimer?.cancel();
    isProcessing = false;
    super.dispose();
  }
}
