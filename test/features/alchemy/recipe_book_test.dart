import 'package:flutter_test/flutter_test.dart';
import 'package:grimoji/config/emojis.dart';
import 'package:grimoji/features/alchemy/reactions/reaction.dart';
import 'package:grimoji/features/alchemy/recipe_book.dart';

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
      expect(dropletRecipe!.yields, equals(Emojis.ocean));
    });

    test('getRecipeFor should return null for normal emojis', () {
      final noEntryRecipe = RecipeBook.getRecipeFor(Emojis.noEntry);
      expect(noEntryRecipe, isNull, reason: 'NoEntry doesn\'t have a special recipe, so it should return null to let the engine handle them normally');
    });

    test('getTransformationsForType should return the correct reaction maps', () {
      final explosiveTransformations = RecipeBook.getTransformationsForType(ReactionType.explosive);
      
      expect(explosiveTransformations, isNotNull);
      expect(explosiveTransformations, isA<Map<GameEmoji, GameEmoji>>());
      
      expect(explosiveTransformations.containsKey(Emojis.ocean), isTrue);
      expect(explosiveTransformations[Emojis.ocean], equals(Emojis.salt));
    });
    
    test('getTransformationsForType should throw StateError if an unregistered ReactionType is requested', () {
      expect(() => RecipeBook.getTransformationsForType(ReactionType.freezing), throwsStateError);
    });

    test('All recipes must have strictly valid data', () {
      for (final recipe in RecipeBook.allRecipes) {
        expect(recipe.yields, isNotNull, 
          reason: '${recipe.ingredient.visual} is a recipe but yields nothing');
      }
    });

    test('Recipes MUST NOT yield their own ingredient', () {
      for (final recipe in RecipeBook.allRecipes) {
        expect(
          recipe.yields, 
          isNot(equals(recipe.ingredient)), 
          reason: 'CRITICAL ERROR: ${recipe.ingredient.visual} yields itself! This will cause an infinite match loop.'
        );
      }
    });

    test('Reactions MUST NOT transform an emoji into itself ', () {
      for (final reaction in RecipeBook.allReactions) {
        reaction.transformations.forEach((inputEmoji, outputEmoji) {
          expect(
            inputEmoji, 
            isNot(equals(outputEmoji)),
            reason: '${reaction.type.name} reaction turns ${inputEmoji.visual} into itself. This is redundant data!'
          );
        });
      }
    });
  });
}