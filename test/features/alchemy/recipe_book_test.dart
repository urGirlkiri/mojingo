import 'package:flutter_test/flutter_test.dart';
import 'package:grimoji/config/emojis.dart';
import 'package:grimoji/features/alchemy/reactions/reaction.dart';
import 'package:grimoji/features/alchemy/recipe_book.dart';
import 'package:grimoji/features/alchemy/recipes/recipe.dart';

void main() {
  group('RecipeBook Tests', () {
    test('allRecipes should not contain duplicate ingredients', () {
      final ingredients = RecipeBook.allRecipes.map((r) => r.ingredient).toList();
      final uniqueIngredients = ingredients.toSet();

      expect(ingredients.length, equals(uniqueIngredients.length), 
        reason: 'There are duplicate recipes for the same ingredient in your data files!');
    });

    test('getRecipeFor should successfully return mapped recipes', () {
      final dropletRecipe = RecipeBook.getRecipeFor(Emojis.droplet);
      expect(dropletRecipe, isNotNull);
      expect(dropletRecipe!.type, equals(RecipeType.merge));
      expect(dropletRecipe.yields, equals(Emojis.ocean));
    });

    test('getRecipeFor should return null for normal emojis', () {
      final rockRecipe = RecipeBook.getRecipeFor(Emojis.rock);
      expect(rockRecipe, isNull, reason: 'Rocks don\'t have a special recipe, so it should return null to let the engine handle them normally');
    });

    test('getReactionsForType should return the correct reaction maps', () {
      final explosiveReactions = RecipeBook.getReactionsForType(ReactionType.explosive);
      
      expect(explosiveReactions, isNotNull);
      expect(explosiveReactions, isA<Map<GameEmoji, GameEmoji>>());
      
      expect(explosiveReactions.containsKey(Emojis.ocean), isTrue);
      expect(explosiveReactions[Emojis.ocean], equals(Emojis.salt));
    });
    
    test('getReactionsForType should throw StateError if an unregistered ReactionType is requested', () {
      expect(() => RecipeBook.getReactionsForType(ReactionType.freezing), throwsStateError);
    });

    test('All recipes must have strictly valid data according to their RecipeType', () {
      for (final recipe in RecipeBook.allRecipes) {
        if (recipe.type == RecipeType.merge) {
          expect(recipe.yields, isNotNull, 
            reason: '${recipe.ingredient.visual} is a Merge recipe but yields nothing');
            
          expect(recipe.blastType, isNull,
            reason: '${recipe.ingredient.visual} is a Merge recipe and should not have a "blastType"!');
            
        } else if (recipe.type == RecipeType.volatile) {
          expect(recipe.blastType, isNotNull, 
            reason: '${recipe.ingredient.visual} is a Volatile recipe but has no "blastType" defined!');
            
          expect(recipe.yields, isNull,
            reason: '${recipe.ingredient.visual} is a Volatile recipe and should not have any yields!');
        }
      }
    });

    test('Recipes MUST NOT yield their own ingredient', () {
      for (final recipe in RecipeBook.allRecipes) {
        if (recipe.type == RecipeType.merge && recipe.yields != null) {
          expect(
            recipe.yields, 
            isNot(equals(recipe.ingredient)), 
            reason: 'CRITICAL ERROR: ${recipe.ingredient.visual} yields itself! This will cause an infinite match loop.'
          );
        }
      }
    });

    test('Reactions MUST NOT transmute an emoji into itself ', () {
      for (final reactionGroup in RecipeBook.allReactions) {
        reactionGroup.reactions.forEach((inputEmoji, outputEmoji) {
          expect(
            inputEmoji, 
            isNot(equals(outputEmoji)),
            reason: '${reactionGroup.type.name} reaction turns ${inputEmoji.visual} into itself. This is redundant data!'
          );
        });
      }
    });
  });
}