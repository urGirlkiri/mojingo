import 'package:grimoji/config/emojis.dart';
import 'package:grimoji/features/alchemy/reactions/reaction.dart';

enum RecipeType {
  merge,  
  volatile, 
  stable   
}

class Recipe {
  final GameEmoji ingredient;
  final int requiredAmount;
  final GameEmoji? yields;
  final RecipeType type;
  
  final ReactionType? blastType; 

  const Recipe({
    required this.ingredient,
    required this.requiredAmount,
    this.yields,
    required this.type,
    this.blastType,
  });
}
