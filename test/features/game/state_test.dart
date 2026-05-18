import 'package:flutter_test/flutter_test.dart';
import 'package:fake_async/fake_async.dart';
import 'package:grimoji/config/emojis.dart';
import 'package:grimoji/config/levels/game_level.dart';
import 'package:grimoji/config/levels/index.dart';
import 'package:grimoji/config/constants.dart';
import 'package:grimoji/features/game/state.dart';
import 'package:grimoji/features/game/model/coordinate.dart';
import 'package:grimoji/utils/test_helpers.dart';

void main() {
  group('GameState tests', () {
    late GameLevel level;

    setUp(() {
      level = const GameLevel(
        number: 1,
        availableEmojis: [Emojis.fire, Emojis.rock, Emojis.droplet, Emojis.alien],
        targetEmoji: Emojis.fire,
        targetAmount: 10,
        timeLimit: 60,
        type: LevelType.puzzle,
      );
    });

    test('Should initialize and start initial drop with gravity', () {
      fakeAsync((async) {
        final state = GameState(
          level: level,
          onEmojiDestroyed: (_, _) {},
          onComboFinished: () => false,
        );

        expect(state.isProcessing, isFalse, reason: 'State should not be processing initially');
        
        state.startInitialDrop();
        expect(state.gameController.grid[0][0].coordinate.row, 0, reason: 'Gravity should position tile at row 0');
      });
    });

    test('Should manage idle timer, hinting, and reset logic', () {
      fakeAsync((async) {
        final state = GameState(
          level: level,
          onEmojiDestroyed: (_, _) {},
          onComboFinished: () => false,
        );

        state.startInitialDrop();
        
        async.elapse(const Duration(seconds: 5));
        
        bool hasHint = state.gameController.grid.any(
          (row) => row.any((tile) => tile.isHinting)
        );
        expect(hasHint, isTrue, reason: 'Hints should appear after 5s idle');

        state.resetTimer();
        hasHint = state.gameController.grid.any(
          (row) => row.any((tile) => tile.isHinting)
        );
        expect(hasHint, isFalse, reason: 'Touching screen should clear hints');
      });
    });

    test('Should restart hint timer after invalid swipe', () {
      fakeAsync((async) {
        final state = GameState(
          level: level,
          onEmojiDestroyed: (_, _) {},
          onComboFinished: () => false,
        );

        TestHelpers.genDeadLockGrid(state.gameController);
        state.startInitialDrop();
        
        async.elapse(const Duration(seconds: 3));
        bool hasHint = state.gameController.grid.any(
          (row) => row.any((tile) => tile.isHinting)
        );
        expect(hasHint, isFalse, reason: 'No hint should appear before 5s');
        
        state.resolveSwipe(TileCoordinate(row: 0, col: 0), TileCoordinate(row: 0, col: 1));
        async.elapse(swapAnimationTime * 2 + const Duration(milliseconds: 400) + shuffleWipeTime * 2);
        
        state.gameController.grid[5][0].emoji = Emojis.fire;
        state.gameController.grid[6][0].emoji = Emojis.fire;
        state.gameController.grid[7][1].emoji = Emojis.fire;
        
        async.elapse(const Duration(seconds: 5));
        hasHint = state.gameController.grid.any(
          (row) => row.any((tile) => tile.isHinting)
        );
        expect(hasHint, isTrue, reason: 'Hint should appear 5s after swipe (timer restarted)');
      });
    });

    test('Should resolve invalid swipe by swapping and reverting', () {
      fakeAsync((async) {
        final state = GameState(
          level: level,
          onEmojiDestroyed: (_, _) {},
          onComboFinished: () => false,
        );

        TestHelpers.genDeadLockGrid(state.gameController);

        state.gameController.grid[0][0].emoji = Emojis.droplet;
        state.gameController.grid[0][1].emoji = Emojis.droplet;
        state.gameController.grid[1][0].emoji = Emojis.fire;
        state.gameController.grid[1][1].emoji = Emojis.fire;

        state.resolveSwipe(TileCoordinate(row: 0, col: 0), TileCoordinate(row: 0, col: 1));
        
        expect(state.isProcessing, isTrue, reason: 'State should be processing during swap');
        
        async.elapse(swapAnimationTime * 2 + const Duration(milliseconds: 400));

        expect(state.gameController.grid[0][0].emoji, Emojis.droplet, reason: 'Grid should revert after invalid swap');
        expect(state.isProcessing, isFalse, reason: 'State should stop processing after revert');
      });
    });

    test('Should resolve valid swipe with cascade and turn end behaviors', () {
      fakeAsync((async) {
        final state = GameState(
          level: level,
          onEmojiDestroyed: (_, _) {},
          onComboFinished: () => false,
        );

        TestHelpers.genDeadLockGrid(state.gameController);
        state.gameController.grid[0][0].emoji = Emojis.fire;
        state.gameController.grid[0][1].emoji = Emojis.fire;
        state.gameController.grid[1][2].emoji = Emojis.fire;

        state.resolveSwipe(TileCoordinate(row: 0, col: 2), TileCoordinate(row: 1, col: 2));
        
        int safeTimeLimit = 200; 
        while (state.isProcessing && safeTimeLimit > 0) {
          async.elapse(const Duration(milliseconds: 100));
          safeTimeLimit--;
        }

        expect(state.isProcessing, isFalse, reason: 'Processing should complete after valid match');
      });
    });

    test('Should execute shuffleBoard flow with progress tracking', () {
      fakeAsync((async) {
        final state = GameState(
          level: level,
          onEmojiDestroyed: (_, _) {},
          onComboFinished: () => false,
        );

        state.shuffleBoard();
        expect(state.shuffleProgress, 0.0, reason: 'Shuffle progress should start at 0');
        
        async.elapse(const Duration(milliseconds: 600));
        expect(state.shuffleProgress, 1.0, reason: 'Shuffle progress should complete after animation');
        
        async.elapse(const Duration(milliseconds: 600));
      });
    });

    test('Should resolve emoji and track goal progress', () {
      final state = GameState(
        level: level,
        onEmojiDestroyed: (_, _) {},
        onComboFinished: () => false,
      );

      state.resolveEmoji(Emojis.fire, 3);
      expect(state.hasTargetCombo, isTrue, reason: 'Matching target emoji should set target flag');
      
      state.resolveEmoji(Emojis.rock, 3);
    });

    test('Should dispose and cleanup resources', () {
      final state = GameState(
        level: level,
        onEmojiDestroyed: (_, _) {},
        onComboFinished: () => false,
      );
      
      state.dispose();
      expect(state.isProcessing, isFalse, reason: 'State should not be processing after dispose');
    });

    test('Should not trigger hint when processing', () {
      fakeAsync((async) {
        final state = GameState(
          level: level,
          onEmojiDestroyed: (_, _) {},
          onComboFinished: () => false,
        );

        TestHelpers.genDeadLockGrid(state.gameController);
        state.startInitialDrop();
        
        state.gameController.grid[0][0].emoji = Emojis.fire;
        state.gameController.grid[0][1].emoji = Emojis.fire;
        
        state.resolveSwipe(TileCoordinate(row: 0, col: 2), TileCoordinate(row: 1, col: 2));
        
        async.elapse(swapAnimationTime * 2 + const Duration(seconds: 10));
        
        expect(state.isProcessing, isFalse, reason: 'Processing should complete');
      });
    });

    test('Should not trigger hint when shuffling', () {
      fakeAsync((async) {
        final state = GameState(
          level: level,
          onEmojiDestroyed: (_, _) {},
          onComboFinished: () => false,
        );

        state.startInitialDrop();
        state.shuffleBoard();
        
        async.elapse(const Duration(seconds: 10));
        
        expect(state.isShuffling, isFalse, reason: 'Shuffling should complete');
      });
    });

    test('Should not trigger hint after game over', () {
      fakeAsync((async) {
        final state = GameState(
          level: level,
          onEmojiDestroyed: (_, _) {},
          onComboFinished: () => false,
        );

        state.startInitialDrop();
        state.setGameOver();
        
        async.elapse(const Duration(seconds: 10));
        
        bool hasHint = state.gameController.grid.any(
          (row) => row.any((tile) => tile.isHinting)
        );
        expect(hasHint, isFalse, reason: 'Hints should not appear after game over');
      });
    });

    test('Should clear hints on game over', () {
      fakeAsync((async) {
        final state = GameState(
          level: level,
          onEmojiDestroyed: (_, _) {},
          onComboFinished: () => false,
        );

        state.startInitialDrop();
        async.elapse(const Duration(seconds: 3));
        
        state.setGameOver();
        
        async.elapse(const Duration(seconds: 10));
        
        bool hasHint = state.gameController.grid.any(
          (row) => row.any((tile) => tile.isHinting)
        );
        expect(hasHint, isFalse, reason: 'Hints should be cleared on game over');
      });
    });

    test('Should set hint partner on hint tiles', () {
      fakeAsync((async) {
        final state = GameState(
          level: level,
          onEmojiDestroyed: (_, _) {},
          onComboFinished: () => false,
        );

        TestHelpers.genDeadLockGrid(state.gameController);
        state.gameController.grid[0][0].emoji = Emojis.fire;
        state.gameController.grid[0][1].emoji = Emojis.fire;
        state.gameController.grid[1][2].emoji = Emojis.fire;
        
        state.startInitialDrop();
        
        async.elapse(const Duration(seconds: 5));
        
        TileCoordinate? hintingCoord;
        TileCoordinate? partnerCoord;
        
        for (int r = 0; r < state.gameController.getRowCount(); r++) {
          for (int c = 0; c < state.gameController.getColCount(); c++) {
            if (state.gameController.grid[r][c].isHinting) {
              hintingCoord ??= TileCoordinate(row: r, col: c);
              partnerCoord = state.gameController.grid[r][c].hintPartner;
            }
          }
        }
        
        expect(hintingCoord, isNotNull, reason: 'At least one tile should be hinting');
        expect(partnerCoord, isNotNull, reason: 'Hinting tile should have a partner');
      });
    });

    test('Should clear hints on resetTimer', () {
      fakeAsync((async) {
        final state = GameState(
          level: level,
          onEmojiDestroyed: (_, _) {},
          onComboFinished: () => false,
        );

        state.startInitialDrop();
        async.elapse(const Duration(seconds: 5));
        
        bool hasHint = state.gameController.grid.any(
          (row) => row.any((tile) => tile.isHinting)
        );
        expect(hasHint, isTrue, reason: 'Hints should appear after 5s idle');
        
        state.resetTimer();
        
        hasHint = state.gameController.grid.any(
          (row) => row.any((tile) => tile.isHinting)
        );
        expect(hasHint, isFalse, reason: 'Hints should be cleared on resetTimer');
      });
    });

    test('Should not trigger hint on disposed state', () {
      fakeAsync((async) {
        final state = GameState(
          level: level,
          onEmojiDestroyed: (_, _) {},
          onComboFinished: () => false,
        );

        state.startInitialDrop();
        state.dispose();
        
        async.elapse(const Duration(seconds: 10));
        
        bool hasHint = state.gameController.grid.any(
          (row) => row.any((tile) => tile.isHinting)
        );
        expect(hasHint, isFalse, reason: 'Hints should not appear on disposed state');
      });
    });
  });
}