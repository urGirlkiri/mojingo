import 'package:grimoji/config/emojis.dart';
import 'package:grimoji/features/alchemy/reactions/reaction.dart';
import 'package:grimoji/features/alchemy/reactions/elemental_explosions.dart';
import 'package:grimoji/features/alchemy/reactions/nature_explosions.dart';
import 'package:grimoji/features/alchemy/recipes/recipe.dart';
import 'package:grimoji/features/alchemy/recipes/elements.dart';
import 'package:grimoji/features/alchemy/recipes/nature.dart';

class RecipeBook {
  static const List<Recipe> allRecipes = [
    ...elementalRecipes,
    ...natureRecipes,
  ];

  static final List<Reaction> allReactions = [
    NatureExplosions(),
    ElementalExplosions(),
  ];

  static final Map<GameEmoji, Recipe> _recipeCache = {
    for (var recipe in allRecipes) recipe.ingredient: recipe
  };

  static Recipe? getRecipeFor(GameEmoji emoji) {
    return _recipeCache[emoji]; 
  }

  static Map<GameEmoji, GameEmoji> getReactionsForType(ReactionType type) {
    final reaction = allReactions.firstWhere(
      (recipe) => recipe.type == type,
    );
    return reaction.reactions ;
  }
}