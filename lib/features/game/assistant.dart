import 'dart:async';
import 'package:grimoji/config/constants.dart';
import 'package:grimoji/features/game/model/coordinate.dart';
import 'package:grimoji/features/game/model/match_detector.dart';
import 'package:grimoji/features/game/model/swipe_detector.dart';
import 'package:grimoji/features/game/model/tile.dart';
import 'package:grimoji/features/game/state.dart';

class BoardAssistant {
  final GameState _state;
  Timer? _hintTimer;
  List<TileCoordinate>? currentHints;
  double shuffleProgress = 1.0;

  BoardAssistant(this._state);

  void startHintTimer() {
    _hintTimer?.cancel();
    _hintTimer = Timer(const Duration(seconds: 5), _triggerHint);
  }

  void resetTimer() {
    if (_state.isDisposed) return;
    if (_state.isGameOver) {
      _hintTimer?.cancel();
      return;
    }

    clearHint();
    if (!_state.isProcessing && !_state.isShuffling) {
      startHintTimer();
    }
    _state.updateUI();
  }

  void _triggerHint() {
    if (_state.isProcessing || _state.isShuffling || _state.isDisposed || _state.isGameOver) {
      return;
    }

    currentHints = _state.gameController.getHintMove();
    if (currentHints != null) {
      Tile tileA = _state.gameController.grid[currentHints![0].row][currentHints![0].col];
      Tile tileB = _state.gameController.grid[currentHints![1].row][currentHints![1].col];

      tileA.isHinting = true;
      tileA.hintPartner = tileB.coordinate;
      tileB.isHinting = true;
      tileB.hintPartner = tileA.coordinate;

      _state.updateUI();
    } else {
      shuffleBoard();
    }
  }

  void clearHint() {
    _hintTimer?.cancel();
    currentHints = null;

    for (int r = 0; r < _state.gameController.getRowCount(); r++) {
      for (int c = 0; c < _state.gameController.getColCount(); c++) {
        _state.gameController.grid[r][c].isHinting = false;
        _state.gameController.grid[r][c].hintPartner = null;
      }
    }
    _state.updateUI();
  }

  Future<void> shuffleBoard() async {
    shuffleProgress = 0.0;
    _state.setShufflingFlag(true);
    _state.updateUI();

    await Future.delayed(const Duration(milliseconds: 600));
    _state.gameController.shuffleGrid();

    shuffleProgress = 1.0;
    _state.updateUI();

    await Future.delayed(const Duration(milliseconds: 600));
    _state.setShufflingFlag(false);
    
    if (!_state.isDisposed) {
      _state.updateUI();
      resetTimer();
    }
  }

  Future<List<MatchGroup>> attemptSwap(TileCoordinate dCoord, TileCoordinate tCoord) async {
    final decision = _state.gameController.evaluateSwipe(dCoord, tCoord);

    if (decision.type == SwipeResult.invalid) {
      _state.gameController.swapTiles(dCoord, tCoord);
      _state.updateUI();

      await Future.delayed(swapAnimationTime);
      if (_state.isDisposed) return [];

      _state.gameController.swapTiles(tCoord, dCoord);
      _state.updateUI();

      if (!_state.isDisposed) {
        clearHint();
        startHintTimer();
      }
      return [];
    } else {
      _state.updateUI();
      await Future.delayed(const Duration(milliseconds: 100));
      if (_state.isDisposed) return [];

      if (decision.type == SwipeResult.specialBehavior) {
        _state.gameController.executeBehaviorActions(decision.actions, dCoord.row, dCoord.col);
        return [];
      }

      return decision.matches;
    }
  }

  void cancelHintTimer() {
    _hintTimer?.cancel();
  }
}