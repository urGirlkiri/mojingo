import 'package:grimoji/config/emojis.dart';
import 'package:grimoji/features/level/game/model/alchemy/recipe_type.dart';

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
