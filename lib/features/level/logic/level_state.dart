import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:grimoji/config/levels.dart';
import 'package:logging/logging.dart';

class LevelState extends ChangeNotifier {
  final void Function(int stars) onWin;
  final VoidCallback onFail;
  final GameLevel level;
  final Logger _log = Logger('LevelState');

  LevelState({
    required this.onWin,
    required this.onFail,
    required this.level,
  });

  final Stopwatch _stopwatch = Stopwatch();
  Timer? _ticker;

  late int _secondsRemaining = level.timeLimit; 

  int get secondsRemaining => _secondsRemaining;
  bool get isPaused => !_stopwatch.isRunning;

  void startLevel() {
    _stopwatch.start();
    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_stopwatch.isRunning) {
        _secondsRemaining--;
        if (_secondsRemaining <= 0) {
          _secondsRemaining = 0;
          stopLevel();
          onFail();
        }
        notifyListeners();
      }
    });
  }

  void togglePause() {
    _log.info('Toggling pause. Currently paused: $isPaused');
    if (_stopwatch.isRunning) {
      _stopwatch.stop();
    } else {
      _stopwatch.start();
    }
    notifyListeners();
  }

  void stopLevel() {
    _stopwatch.stop();
    _ticker?.cancel();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void evaluate() {
  }
}
