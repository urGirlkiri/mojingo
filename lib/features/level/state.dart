import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:grimoji/config/emojis.dart';
import 'package:grimoji/config/levels.dart';
import 'package:grimoji/features/level/game/controller.dart';
import 'package:grimoji/features/level/game/model/coordinate.dart';
import 'package:grimoji/features/level/game/model/match_detector.dart';
import 'package:logging/logging.dart';

class LevelState extends ChangeNotifier {
  final void Function(int stars) onWin;
  final VoidCallback onLose;
  final GameLevel level;

  final Stopwatch _stopwatch = Stopwatch();
  final Logger _log = Logger('LevelState');

  late final GameController gameController;
  late int _secondsRemaining = level.timeLimit;

  LevelState({required this.onWin, required this.onLose, required this.level}) {
    gameController = GameController(level);
    gameController.initialize();
  }

  Timer? _ticker;

  bool isProcessing = false;
  bool hasTargetCombo = false;
  bool isPaused = false;
  bool isDisposed = false;
  bool isGameOver = false;

  int collectedAmount = 0;

  int get secondsRemaining => _secondsRemaining;
  double get progress => (collectedAmount / level.targetAmount).clamp(0.0, 1.0);

  int calculateStars() {
    if (progress >= 1.00) return 3;
    if (progress >= 0.66) return 2;
    if (progress >= 0.30) return 1;
    return 0;
  }

  void evaluateGameEnd() {
    if (isGameOver) return;
    _ticker?.cancel();

    int earnedStars = calculateStars();
        _log.info('earned $earnedStars');


    if (earnedStars >= 1) {
      onWin.call(earnedStars);
    } else {
      onLose.call();
    }
  }

  void startLevel() {
    _stopwatch.start();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _onTimerTick());
  }

  void _onTimerTick() {
    if (isDisposed) return;
    if (!_stopwatch.isRunning) return;

    if (_secondsRemaining > 0) {
      _secondsRemaining--;
      notifyListeners();
    } else {
      if (!isProcessing) {
        evaluateGameEnd();
      }
    }
  }

  void startInitialDrop() async {
    _log.info('Starting to drop emojis');
    startLevel();
    gameController.triggerInitialFall();
    notifyListeners();
  }

  void togglePause() {
    isPaused = !isPaused;
    _log.info('Toggling pause. Currently paused: $isPaused');
    if (_stopwatch.isRunning) {
      _stopwatch.stop();
    } else {
      _stopwatch.start();
    }
    notifyListeners();
  }

  void onBoardUpdated() {
    notifyListeners();
  }

  Future<void> resolveSwipe(
    TileCoordinate draggedCoordinate,
    TileCoordinate targetCoordinate,
  ) async {
    isProcessing = true;
    notifyListeners();

    final TileCoordinate originalDCoordinate = TileCoordinate(
      row: draggedCoordinate.row,
      col: draggedCoordinate.col,
    );
    final TileCoordinate originalTCoordinate = TileCoordinate(
      row: targetCoordinate.row,
      col: targetCoordinate.col,
    );

    gameController.swapTiles(originalDCoordinate, originalTCoordinate);
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 300));
    if (isDisposed) return;

    Set<TileCoordinate> matches = MatchDetector.findMatches(
      gameController.grid,
    );

    if (matches.isEmpty) {
      _log.info('Invalid Move! Reverting swap.');
      gameController.swapTiles(originalTCoordinate, originalDCoordinate);
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 300));
      if (isDisposed) return;

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
      if (isDisposed) return;

      gameController.triggerInitialFall();
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 800));
      if (isDisposed) return;

      matches = MatchDetector.findMatches(gameController.grid);
      if (matches.isEmpty) {
        hasCombos = false;
      } else {
        _log.info('COMBO DETECTED! Looping again...');
        isFirstMatch = false;
      }
    }

    hasTargetCombo = false;
    isProcessing = false;
    if (isDisposed) return;

    if (progress >= 1.0) {
      evaluateGameEnd();
      return;
    }

    if (_secondsRemaining <= 0) {
      evaluateGameEnd();
      return;
    }

    notifyListeners();
  }

  void stopLevel() {
    _stopwatch.stop();
    _ticker?.cancel();
  }

  void resolveEmoji(GameEmoji destroyedEmoji, int count) {
    if (destroyedEmoji == level.targetEmoji) {
      collectedAmount += count;
      hasTargetCombo = true;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    isDisposed = true;
    _ticker?.cancel();
    _stopwatch.stop(); 
    super.dispose();
  }
}
