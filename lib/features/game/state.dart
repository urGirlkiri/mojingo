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
    _hintTimer?.cancel();
    _hintTimer = Timer(const Duration(seconds: 5), _triggerHint);
  }

  void resetTimer() {
    if (_isDisposed) return;

    if (_isGameOver) {
      _hintTimer?.cancel();
      return;
    }

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
    gameController.triggerInitialFall();
    notifyListeners();
    resetTimer();
  }

  void setGameOver() {
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
      return;
    }

    isProcessing = true;
    resetTimer();
    notifyListeners();

    List<MatchGroup> matchedGroups = await _attemptSwap(
      draggedCoordinate,
      targetCoordinate,
    );

    if (matchedGroups.isEmpty) {
      hasTargetCombo = false;

      isProcessing = false;
      if (!_isDisposed) {
        notifyListeners();
        resetTimer();
      }
      return;
    }

    bool isFirstMatch = true;

    while (matchedGroups.isNotEmpty) {
      _log.info('Processing ${matchedGroups.length} groups...');

      _categorizeAnimations(matchedGroups, isFirstMatch, targetCoordinate);
      notifyListeners();
      await Future.delayed(clearAnimationTime);
      if (_isDisposed) return;

      final Set<TileCoordinate> allMatchedCoords = matchedGroups
          .expand((g) => g.coordinates)
          .toSet();
      gameController.spawnTiles(
        allMatchedCoords,
        this,
        mergePoint: isFirstMatch ? targetCoordinate : null,
      );

      await Future.delayed(const Duration(milliseconds: 400));
      if (_isDisposed) return;

      bool collected = gameController.collectFlyingTiles();
      if (collected) {
        notifyListeners();
      }
      gameController.triggerInitialFall();
      notifyListeners();

      await Future.delayed(gravityAnimationTime);
      if (_isDisposed) return;

      matchedGroups = MatchDetector.findMatchedGroups(gameController.grid);
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
    if (isProcessing || isShuffling || _isDisposed || _isGameOver) {
      return;
    }

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
    final decision = gameController.evaluateSwipe(dCoord, tCoord);

    if (decision.type == SwipeResult.invalid) {
      _log.info('Invalid swap - playing snap-back animation');

      gameController.swapTiles(dCoord, tCoord);
      notifyListeners();

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
      notifyListeners();
      await Future.delayed(Duration(milliseconds: 100) );
      if (_isDisposed) return [];

      if (decision.type == SwipeResult.specialBehavior) {
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
    List<MatchGroup> matchedGroups,
    bool isFirstMatch,
    TileCoordinate targetCoord,
  ) {
    for (var groupMatch in matchedGroups) {
      final recipe = RecipeBook.getRecipeFor(groupMatch.emoji);

      if (recipe != null) {
        TileCoordinate catalyst =
            (isFirstMatch && groupMatch.coordinates.contains(targetCoord))
            ? targetCoord
            : groupMatch.coordinates.first;

        for (var coord in groupMatch.coordinates) {
          final tile = gameController.grid[coord.row][coord.col];

          tile.isMergePoint = coord == catalyst;

          if (!tile.isMergePoint) {
            tile.isMerging = true;
            tile.coordinate.col = catalyst.col;
            tile.coordinate.row = catalyst.row;
          } else {
            tile.morphTarget = recipe.yields; 
          }
        }
      } else {
        for (var coord in groupMatch.coordinates) {
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
