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
    NatureReactions(),
    ElementalReactions(),
  ];

  static final Map<GameEmoji, List<Recipe>> _recipeCache = {};
  static final Map<GameEmoji, Reaction> _triggerCache = {};
  static bool _isInitialized = false;

  static void _ensureInitialized() {
    if (_isInitialized) return;
    _isInitialized = true;
    
    for (var recipe in allRecipes) {
      _recipeCache.putIfAbsent(recipe.ingredient, () => []).add(recipe);
    }
    
    for (var list in _recipeCache.values) {
      list.sort((a, b) => b.requiredAmount.compareTo(a.requiredAmount));
    }

    for (final reaction in allReactions) {
      for (final trigger in reaction.triggers) {
        _triggerCache[trigger] = reaction;
      }
    }
  }

  static List<Recipe>? getRecipesFor(GameEmoji emoji) {
    _ensureInitialized();
    return _recipeCache[emoji]; 
  }

  static Reaction? getReactionFor(GameEmoji emoji) {
    _ensureInitialized();
    return _triggerCache[emoji];
  }

  static Map<GameEmoji, GameEmoji> getTransformationsForType(ReactionType type) {
    final reaction = allReactions.firstWhere(
      (r) => r.type == type,
    );
    return reaction.transformations;
  }

  static int getAoERadiusForType(ReactionType type) {
    final reaction = allReactions.firstWhere(
      (r) => r.type == type,
    );
    return reaction.aoeRadius;
  }

  static void initialize() {
    _ensureInitialized();
  }

  static Recipe? getRecipeFor(GameEmoji emoji) {
    _ensureInitialized();
    final recipes = _recipeCache[emoji];
    return recipes?.isNotEmpty == true ? recipes!.first : null;
  }
}