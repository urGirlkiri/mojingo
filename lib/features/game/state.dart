import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:grimoji/config/constants.dart';
import 'package:grimoji/config/emojis.dart';
import 'package:grimoji/config/levels.dart';
import 'package:grimoji/features/alchemy/recipe_book.dart';
import 'package:grimoji/features/alchemy/reactions/reaction.dart';
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

  bool isPaused = false;

  int currentComboMultiplier = 0;

  String? activeAnnouncement;
  int announcementToken = 0;

  void announce(String phrase) {
    activeAnnouncement = phrase;
    announcementToken++;
    notifyListeners();

    final currentToken = announcementToken;
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (!_isDisposed && announcementToken == currentToken) {
        activeAnnouncement = null;
        notifyListeners();
      }
    });
  }

  List<TileCoordinate>? _currentHints;

  Future<void> _waitIfPaused() async {
    while (isPaused) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

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
    if (_isGameOver || isPaused) {
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

    activeAnnouncement = null;

    bool isFirstMatch = true;

    while (true) {
      await _waitIfPaused();

      bool hasMatches = true;
      while (hasMatches) {
        await _waitIfPaused();

        List<MatchGroup> matchedGroups = MatchDetector.findMatchedGroups(
          gameController.grid,
        );

        matchedGroups.removeWhere((group) {
          return group.coordinates.any((c) {
            final tile = gameController.grid[c.row][c.col];
            return tile.isTriggered || tile.isExploding || tile.isMerging;
          });
        });

        if (matchedGroups.isEmpty) {
          hasMatches = false;
          break;
        }

        if (!isFirstMatch) {
          currentComboMultiplier++;
        }

        _categorizeAnimations(matchedGroups, isFirstMatch, targetCoordinate);
        notifyListeners();

        await Future.delayed(clearAnimationTime);
        if (_isDisposed) return;

        final Set<TileCoordinate> allMatchedCoords = matchedGroups
            .expand((g) => g.coordinates)
            .toSet();

        Set<TileCoordinate> reactionDestroyed = gameController.spawnTiles(
          allMatchedCoords,
          this,
          mergePoint: isFirstMatch ? targetCoordinate : null,
        );

        for (var coord in reactionDestroyed) {
          final tile = gameController.grid[coord.row][coord.col];
          if (tile.emoji == gameController.level.targetEmoji) {
            tile.isFlying = true;
          }
        }

        notifyListeners();

        bool hasAoE = reactionDestroyed.any(
          (coord) => !allMatchedCoords.any(
            (c) => c.row == coord.row && c.col == coord.col,
          ),
        );
        bool hasTransmutations = gameController.grid.any(
          (row) => row.any((t) => t.isTransmuting),
        );

        bool containsRecipeMerge = matchedGroups.any(
          (g) => RecipeBook.getRecipeFor(g.emoji) != null,
        );
        if ((hasAoE || hasTransmutations) &&
            (containsRecipeMerge || hasTransmutations)) {
              Future.delayed(const Duration(milliseconds: 500), () {
                announce("Alchemy!");
              });
        }

        if (hasAoE || hasTransmutations) {
          await Future.delayed(clearAnimationTime);
          if (_isDisposed) return;

          for (int r = 0; r < gameController.getRowCount(); r++) {
            for (int c = 0; c < gameController.getColCount(); c++) {
              gameController.grid[r][c].isTransmuting = false;
            }
          }
        } else {
          await Future.delayed(const Duration(milliseconds: 100));
          if (_isDisposed) return;
        }

        gameController.gridManager.applyGravity(reactionDestroyed);

        gameController.collectFlyingTiles();

        notifyListeners();
        await Future.delayed(const Duration(milliseconds: 50));
        if (_isDisposed) return;

        gameController.triggerInitialFall();
        notifyListeners();

        await Future.delayed(gravityAnimationTime);
        if (_isDisposed) return;

        isFirstMatch = false;
      }

      List<Tile> primedBombs = gameController.getTriggeredBombs();

      if (primedBombs.isNotEmpty) {
        await _waitIfPaused();

        Future.delayed(const Duration(milliseconds: 500), () {
          announce("Calamity!");
        });

        Set<TileCoordinate> allBlastedCoords = {};
        Set<TileCoordinate> allTransformedCoords = {};

        final detonatedBombs = <Tile>{};

        bool chainReaction = true;
        while (chainReaction) {
          await _waitIfPaused();

          chainReaction = false;
          final currentBombs = List<Tile>.from(primedBombs);

          for (Tile activeBomb in currentBombs) {
            if (!activeBomb.isTriggered) continue;

            detonatedBombs.add(activeBomb);

            if (activeBomb.emoji == gameController.level.targetEmoji) {
              resolveEmoji(activeBomb.emoji, 1);
            }

            activeBomb.isTriggered = false;
            activeBomb.isExploding = true;

            final blastResult = gameController.executeBlastRadius(
              activeBomb.coordinate,
            );
            allBlastedCoords.addAll(blastResult.destroyed);
            allTransformedCoords.addAll(blastResult.transformed);
          }

          primedBombs = gameController.getTriggeredBombs();
          if (primedBombs.isNotEmpty) {
            chainReaction = true;
          }
        }

        for (var coord in allBlastedCoords) {
          final tile = gameController.grid[coord.row][coord.col];
          if (tile.emoji == gameController.level.targetEmoji) {
            tile.isFlying = true;
          }
        }

        notifyListeners();

        await Future.delayed(clearAnimationTime);
        if (_isDisposed) return;

        for (var coord in allTransformedCoords) {
          final tile = gameController.grid[coord.row][coord.col];
          resolveEmoji(tile.emoji, 1);
          if (tile.emoji == gameController.level.targetEmoji) {
            tile.isFlying = true;
          }
        }

        for (int r = 0; r < gameController.getRowCount(); r++) {
          for (int c = 0; c < gameController.getColCount(); c++) {
            gameController.grid[r][c].isTransmuting = false;
          }
        }

        gameController.gridManager.applyGravity(allBlastedCoords);
        gameController.collectFlyingTiles();

        notifyListeners();
        await Future.delayed(const Duration(milliseconds: 50));
        if (_isDisposed) return;

        gameController.triggerInitialFall();
        notifyListeners();

        await Future.delayed(gravityAnimationTime);
        if (_isDisposed) return;
      } else {
        break;
      }
    }

    if (currentComboMultiplier > 0) {
      if (currentComboMultiplier == 1) {
        announce("Wicked!");
      } else if (currentComboMultiplier == 2) {
        announce("Diabolical!");
      } else if (currentComboMultiplier == 3) {
        announce("Sorcery!");
      } else if (currentComboMultiplier >= 4) {
        announce("MAGICAL!!");
      }
      currentComboMultiplier = 0;
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
      shuffleBoard();
    }
  }

  void _clearHint() {
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
      await Future.delayed(Duration(milliseconds: 100));
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
      final reaction = RecipeBook.getReactionFor(groupMatch.emoji);

      if (recipe != null &&
          groupMatch.coordinates.length >= recipe.requiredAmount) {
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
      } else if (reaction != null && reaction.type == ReactionType.explosive) {
        continue;
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

  void togglePause() {
    isPaused = !isPaused;
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
