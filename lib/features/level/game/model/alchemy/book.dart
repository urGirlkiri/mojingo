import 'package:grimoji/config/emojis.dart';

enum RecipeType {
  merge,    
  volatile, 
}

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
      ingredient: Emojis.salt,
      requiredAmount: 3,
      yields: Emojis.fishingPole,
      type: RecipeType.merge,
    ),

    Recipe(
      ingredient: Emojis.ocean,
      requiredAmount: 3,
      yields: Emojis.cloud,
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
      type: RecipeType.volatile,
    ),

    Recipe(
      ingredient: Emojis.bomb,
      requiredAmount: 3,
      yields: null, 
      type: RecipeType.volatile, 
    ),
  ];

  static const Map<GameEmoji, GameEmoji> transmutations = {
    Emojis.wave: Emojis.droplet,
    Emojis.rock: Emojis.volcano, 
    Emojis.ocean: Emojis.salt
  };

  static Recipe? getRecipeFor(GameEmoji emoji) {
    try {
      return recipes.firstWhere((r) => r.ingredient == emoji);
    } catch (e) {
      return null;
    }
  }
}