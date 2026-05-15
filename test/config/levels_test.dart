import 'package:flutter_test/flutter_test.dart';
import 'package:fake_async/fake_async.dart';
import 'package:grimoji/config/levels.dart';
import 'package:grimoji/config/constants.dart';
import 'package:grimoji/config/emojis.dart';
import 'package:grimoji/features/alchemy/recipe_book.dart';
import 'package:grimoji/features/level/state.dart';
import 'package:logging/logging.dart';

const maxMoves = 10000;

void main() {
  Logger.root.level = Level.WARNING;

  group('Levels Test', () {
    for (var level in gameLevels) {
      test('Level ${level.number} target is mathematically craftable', () {
        Set<GameEmoji> craftableEmojis = Set.from(level.availableEmojis);
        bool discoveredNewEmoji = true;

        while (discoveredNewEmoji) {
          discoveredNewEmoji = false;

          for (var recipe in RecipeBook.allRecipes) {
            if (!craftableEmojis.contains(recipe.yields)) {
              if (craftableEmojis.contains(recipe.ingredient)) {
                craftableEmojis.add(recipe.yields);
                discoveredNewEmoji = true;
              }
            }
          }

          for (var reaction in RecipeBook.allReactions) {
            bool hasTrigger = reaction.triggers.any(
              (triggerEmoji) => craftableEmojis.contains(triggerEmoji),
            );

            if (hasTrigger) {
              for (var entry in reaction.transformations.entries) {
                if (craftableEmojis.contains(entry.key) &&
                    !craftableEmojis.contains(entry.value)) {
                  craftableEmojis.add(entry.value);
                  discoveredNewEmoji = true;
                }
              }
            }
          }
        }

        expect(
          craftableEmojis.contains(level.targetEmoji),
          isTrue,
          reason:
              'Level ${level.number} is IMPOSSIBLE! '
              'Target ${level.targetEmoji.visual} cannot be crafted from base emojis: '
              '${level.availableEmojis.map((e) => e.visual).join(', ')}',
        );
      });

      test(
        'Level ${level.number} should be winnable within a reasonable number of moves',
        () {
          fakeAsync((async) {
            int finalStars = 0;
            bool gameEnded = false;

            final levelState = LevelState(
              level: level,
              onWin: (stars) {
                finalStars = stars;
                gameEnded = true;
              },
              onLose: () {
                finalStars = 0;
                gameEnded = true;
              },
            );

            levelState.startLevel();
            async.elapse(gravityAnimationTime);

            int moveCount = 0;
            final state = levelState.gameState;

            while (moveCount < maxMoves && !gameEnded) {
              final hint = state.gameController.getHintMove();

              if (hint != null) {
                state.resolveSwipe(hint[0], hint[1]);

                while (state.isProcessing) {
                  async.elapse(const Duration(milliseconds: 100));
                }

                moveCount++;
              } else {
                state.shuffleBoard();

                while (state.isShuffling) {
                  async.elapse(const Duration(milliseconds: 100));
                }

                state.resetTimer();
                moveCount++;
              }

              async.elapse(const Duration(milliseconds: 500));
            }

            levelState.dispose();

            expect(
              finalStars,
              greaterThanOrEqualTo(1),
              reason:
                  'Auto-player failed to beat Level ${level.number} in $maxMoves moves. '
                  'Collected ${levelState.collectedAmount} / ${level.targetAmount} ${level.targetEmoji.visual}. ',
            );
          });
        },
        skip: level.skipAutoPlayer ? 'Too complex skip' : false,
      );
    }
  });
}