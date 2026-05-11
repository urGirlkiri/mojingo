import 'package:grimoji/config/emojis.dart';

enum RecipeType { merge, volatile }

class Recipe {
  final GameEmoji ingredient;
  final int requiredAmount;
  final GameEmoji? yields;
  final RecipeType type;

  const Recipe({
    required this.ingredient,
    required this.requiredAmount,
    this.yields,
    required this.type,
  });
}

class RecipeBook {
  static const List<Recipe> recipes = [
    Recipe(
      ingredient: Emojis.droplet,
      requiredAmount: 3,
      yields: Emojis.ocean,
      type: RecipeType.merge,
    ),
    Recipe(
      ingredient: Emojis.ocean,
      requiredAmount: 3,
      yields: Emojis.cloud,
      type: RecipeType.merge,
    ),
    Recipe(
      ingredient: Emojis.cloud,
      requiredAmount: 3,
      yields: Emojis.rainbow,
      type: RecipeType.merge,
    ),

    Recipe(
      ingredient: Emojis.leafyGreen,
      requiredAmount: 3,
      yields: Emojis.herb,
      type: RecipeType.merge,
    ),

    Recipe(
      ingredient: Emojis.fire,
      requiredAmount: 3,
      yields: null,
      type: RecipeType.volatile,
    ),
    Recipe(
      ingredient: Emojis.fire,
      requiredAmount: 4,
      yields: Emojis.bomb,
      type: RecipeType.merge,
    ),
    Recipe(
      ingredient: Emojis.bomb,
      requiredAmount: 3,
      yields: null,
      type: RecipeType.volatile,
    ),
  ];

  static const Map<GameEmoji, GameEmoji> transmutations = {
    Emojis.rock: Emojis.gemStone,
    Emojis.evergreenTree: Emojis.fire,
    Emojis.ocean: Emojis.salt,
    Emojis.volcano: Emojis.rock,
    Emojis.gemStone: Emojis.sparkles,
  };

  static Recipe? getRecipeFor(GameEmoji emoji) {
    for (final recipe in recipes) {
      if (recipe.ingredient == emoji) {
        return recipe;
      }
    }
    return null; 
  }
}
