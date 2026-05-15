import 'package:grimoji/config/emojis.dart';
import 'package:grimoji/features/alchemy/recipes/recipe.dart';

const List<Recipe> elementalRecipes = [
  Recipe(
    ingredient: Emojis.droplet,
    requiredAmount: 3,
    yields: Emojis.ocean,
  ),
  Recipe(
    ingredient: Emojis.fire,
    requiredAmount: 4,
    yields: Emojis.bomb,
  ),
];