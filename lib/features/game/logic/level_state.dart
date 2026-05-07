// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/foundation.dart';

/// An extremely silly example of a game state.
///
/// Tracks only a single variable, [progress], and calls [onWin] when
/// the value of [progress] reaches [goal].
class LevelState extends ChangeNotifier {
final void Function(int stars) onWin;
  final VoidCallback onFail;

  final int goal;
  final int maxMoves;

  LevelState({
    required this.onWin,
    required this.onFail,
    required this.goal,
    required this.maxMoves,
  });

  int _progress = 0;
  int _movesUsed = 0;

  int get progress => _progress;

  void setProgress(int value) {
    _progress = value;
    _movesUsed++;
    notifyListeners();
    evaluate();
  }

  int _calculateStars() {
    final int movesLeft = maxMoves - _movesUsed;
    
    if (movesLeft >= (maxMoves * 0.5)) return 3;
    if (movesLeft >= (maxMoves * 0.2)) return 2;
    return 1; 
  }

  void evaluate() {
    if (_progress >= goal) {
      onWin(_calculateStars());
    } else if (_movesUsed >= maxMoves) {
      onFail();
    }
  }
}
