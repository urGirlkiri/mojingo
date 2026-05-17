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
import 'package:grimoji/features/game/model/tile.dart';
import 'package:grimoji/features/game/board/announcer.dart';
import 'package:grimoji/features/game/assistant.dart';
import 'package:logging/logging.dart';

class GameState extends ChangeNotifier {
  final void Function(GameEmoji, int) onEmojiDestroyed;
  final bool Function() onComboFinished;
  late final GameController gameController;
  final Logger _log = Logger('GameState');

  late final BoardAnnouncer announcer;
  late final BoardAssistant assistant;

  bool isProcessing = false;
  bool hasTargetCombo = false;
  bool isShuffling = false;
  bool isPaused = false;
  bool isDisposed = false;
  bool isGameOver = false;

  int currentComboMultiplier = 0;

  String? get activeAnnouncement => announcer.activeAnnouncement;
  int get announcementToken => announcer.announcementToken;
  double get shuffleProgress => assistant.shuffleProgress;

  GameState({
    required GameLevel level,
    required this.onEmojiDestroyed,
    required this.onComboFinished,
  }) {
    gameController = GameController(level);
    gameController.initialize();
    announcer = BoardAnnouncer(this);
    assistant = BoardAssistant(this);
  }

  void updateUI() {
    if (!isDisposed) notifyListeners();
  }

  void setShufflingFlag(bool value) {
    isShuffling = value;
  }

  void startInitialDrop() {
    gameController.triggerInitialFall();
    notifyListeners();
    assistant.resetTimer();
  }

  void setGameOver() {
    isGameOver = true;
    assistant.cancelHintTimer();
    isProcessing = false;
    notifyListeners();
  }

  void resetTimer() {
    assistant.resetTimer();
  }

  Future<void> shuffleBoard() {
    return assistant.shuffleBoard();
  }

  Future<void> resolveSwipe(
    TileCoordinate dCoord,
    TileCoordinate tCoord,
  ) async {
    if (isGameOver || isPaused) return;

    isProcessing = true;
    assistant.resetTimer();
    notifyListeners();

    List<MatchGroup> matchedGroups = await assistant.attemptSwap(
      dCoord,
      tCoord,
    );
    if (matchedGroups.isEmpty) {
      await _finalizeTurnLifecycle();
      return;
    }

    announcer.clear();
    currentComboMultiplier = 0;
    bool turnHadAlchemy = false;
    bool turnHadCalamity = false;

    while (true) {
      int comboBeforeCascade = currentComboMultiplier;

      bool cascadeOccurred = await _executeCascadePhase(tCoord);
      if (isDisposed) return;

      if (cascadeOccurred && currentComboMultiplier > comboBeforeCascade) {
        turnHadAlchemy = true;
      }

      List<Tile> primedBombs = gameController.getTriggeredBombs();
      if (primedBombs.isNotEmpty) {
        if (currentComboMultiplier > 0) {
          _triggerComboAnnouncement();
          currentComboMultiplier = 0;
        } else if (turnHadAlchemy) {
          announcer.announce("Alchemy!");
          turnHadAlchemy = false;
        }
      }

      bool detonationOccurred = await _executeDetonatorPhase();
      if (isDisposed) return;
      if (detonationOccurred) {
        turnHadCalamity = true;
      }

      if (!cascadeOccurred && !detonationOccurred) {
        break;
      }
    }

    if (currentComboMultiplier > 0) {
      _triggerComboAnnouncement();
    } else if (turnHadCalamity) {
      announcer.announce("Calamity!");
    } else if (turnHadAlchemy) {
      announcer.announce("Alchemy!");
    }

    await _finalizeTurnLifecycle();
  }

  Future<bool> _executeCascadePhase(TileCoordinate targetCoordinate) async {
    bool isFirstMatch = true;
    bool executionOccurred = false;

    while (true) {
      await _waitIfPaused();
      List<MatchGroup> matchedGroups = MatchDetector.findMatchedGroups(
        gameController.grid,
      );

      matchedGroups.removeWhere(
        (group) => group.coordinates.any((c) {
          final tile = gameController.grid[c.row][c.col];
          return tile.isTriggered || tile.isExploding || tile.isMerging;
        }),
      );

      if (matchedGroups.isEmpty) break;

      executionOccurred = true;

      if (!isFirstMatch) {
        currentComboMultiplier++;
      }

      _categorizeAnimations(matchedGroups, isFirstMatch, targetCoordinate);
      notifyListeners();
      await Future.delayed(clearAnimationTime);
      if (isDisposed) return false;

      final Set<TileCoordinate> allMatchedCoords = matchedGroups
          .expand((g) => g.coordinates)
          .toSet();
      Set<TileCoordinate> reactionDestroyed = gameController.spawnTiles(
        allMatchedCoords,
        this,
        mergePoint: isFirstMatch ? targetCoordinate : null,
      );

      _flagFlyingTargetEmoji(reactionDestroyed);

      Set<TileCoordinate> mergedFlyingTargets = {};
      for (int r = 0; r < gameController.getRowCount(); r++) {
        for (int c = 0; c < gameController.getColCount(); c++) {
          final tile = gameController.grid[r][c];
          if (tile.isFlying &&
              !reactionDestroyed.any((cd) => cd.row == r && cd.col == c)) {
            mergedFlyingTargets.add(TileCoordinate(row: r, col: c));
          }
        }
      }
      notifyListeners();

      await _evaluateAlchemicalJuice(
        matchedGroups,
        allMatchedCoords,
        reactionDestroyed,
      );

      reactionDestroyed.addAll(mergedFlyingTargets);

      gameController.gridManager.applyGravity(reactionDestroyed);

      for (int r = 0; r < gameController.getRowCount(); r++) {
        for (int c = 0; c < gameController.getColCount(); c++) {
          gameController.grid[r][c].isFlying = false;
        }
      }

      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 50));
      if (isDisposed) return false;

      gameController.triggerInitialFall();
      notifyListeners();
      await Future.delayed(gravityAnimationTime);
      if (isDisposed) return false;

      isFirstMatch = false;
    }

    return executionOccurred;
  }

  Future<bool> _executeDetonatorPhase() async {
    bool executionOccurred = false;

    while (true) {
      List<Tile> primedBombs = gameController.getTriggeredBombs();
      if (primedBombs.isEmpty) break;

      executionOccurred = true;
      await _waitIfPaused();

      Set<TileCoordinate> allBlastedCoords = {};
      Set<TileCoordinate> allTransformedCoords = {};
      bool chainReaction = true;

      while (chainReaction) {
        await _waitIfPaused();
        chainReaction = false;
        final currentBombs = List<Tile>.from(primedBombs);

        for (Tile activeBomb in currentBombs) {
          if (!activeBomb.isTriggered) continue;
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
        if (primedBombs.isNotEmpty) chainReaction = true;
      }

      _flagFlyingTargetEmoji(allBlastedCoords);
      notifyListeners();
      await Future.delayed(clearAnimationTime);
      if (isDisposed) return false;

      Set<TileCoordinate> targetFlyingTransforms = {};
      for (var coord in allTransformedCoords) {
        final tile = gameController.grid[coord.row][coord.col];
        resolveEmoji(tile.emoji, 1);
        if (tile.emoji == gameController.level.targetEmoji) {
          tile.isFlying = true;
          targetFlyingTransforms.add(coord);
        }
      }

      allBlastedCoords.addAll(targetFlyingTransforms);

      _clearTransmutingMatrices();
      gameController.gridManager.applyGravity(allBlastedCoords);

      for (int r = 0; r < gameController.getRowCount(); r++) {
        for (int c = 0; c < gameController.getColCount(); c++) {
          gameController.grid[r][c].isFlying = false;
        }
      }

      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 50));
      if (isDisposed) return false;

      gameController.triggerInitialFall();
      notifyListeners();
      await Future.delayed(gravityAnimationTime);
      if (isDisposed) return false;
    }

    return executionOccurred;
  }

  Future<void> _finalizeTurnLifecycle() async {
    if (!gameController.hasPossibleMoves()) {
      _log.info('NO MOVES LEFT! Shuffling...');
      await assistant.shuffleBoard();
    }

    _log.info('Processing After Turn Emoji Behaviors...');
    gameController.processTurnEndBehaviors();
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 300));
    if (isDisposed) return;

    hasTargetCombo = false;
    isProcessing = false;

    if (!isDisposed) {
      notifyListeners();
      assistant.resetTimer();
      onComboFinished();
    }
  }

  void _triggerComboAnnouncement() {
    if (currentComboMultiplier == 1)
      announcer.announce("Wicked!");
    else if (currentComboMultiplier == 2)
      announcer.announce("Diabolical!");
    else if (currentComboMultiplier == 3)
      announcer.announce("Sorcery!");
    else if (currentComboMultiplier >= 4)
      announcer.announce("MAGICAL!!");
  }

  void _flagFlyingTargetEmoji(Set<TileCoordinate> coordinates) {
    for (var coord in coordinates) {
      final tile = gameController.grid[coord.row][coord.col];
      if (tile.emoji == gameController.level.targetEmoji) {
        tile.isFlying = true;
      }
    }
  }

  Future<void> _evaluateAlchemicalJuice(
    List<MatchGroup> groups,
    Set<TileCoordinate> matches,
    Set<TileCoordinate> destroyed,
  ) async {
    bool hasAoE = destroyed.any(
      (coord) => !matches.any((c) => c.row == coord.row && c.col == coord.col),
    );
    bool hasTransmutations = gameController.grid.any(
      (row) => row.any((t) => t.isTransmuting),
    );

    if (hasAoE || hasTransmutations) {
      await Future.delayed(clearAnimationTime);
      _clearTransmutingMatrices();
    } else {
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  void _clearTransmutingMatrices() {
    for (int r = 0; r < gameController.getRowCount(); r++) {
      for (int c = 0; c < gameController.getColCount(); c++) {
        gameController.grid[r][c].isTransmuting = false;
      }
    }
  }

  Future<void> _waitIfPaused() async {
    while (isPaused) {
      await Future.delayed(const Duration(milliseconds: 100));
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
    if (emoji == gameController.level.targetEmoji) hasTargetCombo = true;
    onEmojiDestroyed(emoji, count);
    notifyListeners();
  }

  void togglePause() {
    isPaused = !isPaused;
    notifyListeners();
  }

  @override
  void dispose() {
    isDisposed = true;
    assistant.cancelHintTimer();
    isProcessing = false;
    super.dispose();
  }
}
