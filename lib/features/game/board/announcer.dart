import 'dart:async';
import 'package:grimoji/features/game/state.dart';

class BoardAnnouncer {
  final GameState _state;

  String? activeAnnouncement;
  int announcementToken = 0;
  int _currentPriority = 0;

  final List<String> _queue = [];
  bool _isLoopActive = false;
  Timer? _displayTimer;

  BoardAnnouncer(this._state);

  int _getPhrasePriority(String phrase) {
    if (phrase.contains("MAGICAL") || phrase.contains("MASTERPIECE") || phrase.contains("Masterful")) return 5;
    if (phrase.contains("Sorcery") || phrase.contains("Sorcerous")) return 4;
    if (phrase.contains("Diabolical")) return 3;
    if (phrase.contains("Calamity")) return 2;
    if (phrase.contains("Alchemy") || phrase.contains("Alchemical")) return 1;
    if (phrase.contains("Wicked")) return 1;
    return 0;
  }

  void announce(String phrase) {
    final incomingPriority = _getPhrasePriority(phrase);

    if (activeAnnouncement != null) {
      String current = activeAnnouncement!;
      bool fused = false;

      if (phrase == "Alchemy!") {
        if (current.contains("Wicked")) {
          phrase = "Wicked Alchemy!";
          fused = true;
        } else if (current.contains("Diabolical")) {
          phrase = "Diabolical Alchemy!";
          fused = true;
        } else if (current.contains("Sorcery") || current.contains("Sorcerous")) {
          phrase = "Sorcerous Alchemy!";
          fused = true;
        } else if (current.contains("MAGICAL")) {
          phrase = "Magical Alchemy!!";
          fused = true;
        } else if (current.contains("MASTERPIECE")) {
          phrase = "Masterful Alchemy!!";
          fused = true;
        }
      } 
      else if (phrase == "Calamity!") {
        if (current.contains("Alchemy") || current.contains("Alchemical")) {
          phrase = "Alchemical Calamity!";
          fused = true;
        } else if (current.contains("Wicked")) {
          phrase = "Wicked Calamity!";
          fused = true;
        } else if (current.contains("Diabolical")) {
          phrase = "Diabolical Calamity!";
          fused = true;
        } else if (current.contains("Sorcery") || current.contains("Sorcerous")) {
          phrase = "Sorcerous Calamity!";
          fused = true;
        } else if (current.contains("MAGICAL")) {
          phrase = "Magical Calamity!!";
          fused = true;
        } else if (current.contains("MASTERPIECE")) {
          phrase = "Catastrophic Masterpiece!!"; 
          fused = true;
        }
      }

      if (fused) {
        activeAnnouncement = phrase;
        _currentPriority = _getPhrasePriority(phrase);
        _state.updateUI();
        _extendActiveDisplay();
        return;
      }

      if (incomingPriority <= _currentPriority && _currentPriority >= 3) {
        return;
      }
    }

    if (_queue.contains(phrase)) return;

    _queue.add(phrase);

    if (!_isLoopActive) {
      _runPlaybackLoop();
    }
  }

  Future<void> _runPlaybackLoop() async {
    _isLoopActive = true;

    while (_queue.isNotEmpty && !_state.isDisposed) {
      final nextPhrase = _queue.removeAt(0);

      activeAnnouncement = nextPhrase;
      announcementToken++;
      _currentPriority = _getPhrasePriority(nextPhrase);
      _state.updateUI();

      await Future.delayed(const Duration(milliseconds: 1000));
    }

    if (!_state.isDisposed) {
      clear();
    }
    _isLoopActive = false;
  }

  void _extendActiveDisplay() {
    _displayTimer?.cancel();

    _displayTimer = Timer(const Duration(milliseconds: 1000), () {
      if (_queue.isEmpty && !_state.isDisposed) {
        clear();
      }
    });
  }

  void clear() {
    _displayTimer?.cancel();
    _queue.clear();
    activeAnnouncement = null;
    _currentPriority = 0;
    _state.updateUI();
  }
}