import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:grimoji/config/emojis.dart';
import 'package:grimoji/config/levels.dart';
import 'package:grimoji/features/level/game/model/game_state.dart';
import 'package:logging/logging.dart';

class LevelState extends ChangeNotifier {
  final void Function(int stars) onWin;
  final VoidCallback onLose;
  final GameLevel level;

  final Stopwatch _stopwatch = Stopwatch();
  final Logger _log = Logger('LevelState');
  final GlobalKey targetIconKey = GlobalKey();
  Timer? _ticker;

  bool isPaused = false;
  bool _isDisposed = false;
  bool _isGameOver = false;
  int collectedAmount = 0;

  late final GameState gameState;

  LevelState({required this.onWin, required this.onLose, required this.level}) {
    gameState = GameState(
      level: level,
      onEmojiDestroyed: _onEmojiDestroyed,
      onComboFinished: _evaluateGameEnd,
    );

    gameState.addListener(notifyListeners);
  }

  int get secondsRemaining =>
      max(0, level.timeLimit - _stopwatch.elapsed.inSeconds);
  double get progress => (collectedAmount / level.targetAmount).clamp(0.0, 1.0);

  int _calculateStars() {
    if (progress >= 1.00) return 3;
    if (progress >= 0.66) return 2;
    if (progress >= 0.33) return 1;
    return 0;
  }

  void startLevel() {
    _stopwatch.start();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _onTimerTick());
    gameState.startInitialDrop();
  }

  void _onTimerTick() {
    if (_isDisposed || !_stopwatch.isRunning) return;

    notifyListeners();

    if (secondsRemaining <= 0 && !gameState.isProcessing) {
      _evaluateGameEnd();
    }
  }

  void _onEmojiDestroyed(GameEmoji emoji, int count) {
    if (emoji == level.targetEmoji) {
      collectedAmount += count;
      notifyListeners();
    }
  }

  bool _evaluateGameEnd() {
    if (_isGameOver) return true;

    if (progress >= 1.0 || (secondsRemaining <= 0 && !gameState.isProcessing)) {
      _isGameOver = true;
      _ticker?.cancel();
      _stopwatch.stop();

      int earnedStars = _calculateStars();
      if (earnedStars >= 1) {
        _log.info("GAME OVER! Earned $earnedStars stars. YOU WIN!");
        onWin.call(earnedStars);
      } else {
        _log.info("OUT OF TIME! 0 Stars. YOU LOSE!");
        onLose.call();
      }
    }

    return true;
  }

  void togglePause() {
    isPaused = !isPaused;
    isPaused ? _stopwatch.stop() : _stopwatch.start();
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _ticker?.cancel();
    _stopwatch.stop();
    gameState.removeListener(notifyListeners);
    gameState.dispose();
    super.dispose();
  }
}
