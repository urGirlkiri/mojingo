import 'package:grimoji/config/emojis.dart';
import 'package:grimoji/features/alchemy/reactions/reaction.dart';

class ElementalExplosions extends Reaction {
  ElementalExplosions() : super(ReactionType.explosive, _reactions);

  static const Map<GameEmoji, GameEmoji> _reactions = {
    Emojis.ocean: Emojis.salt,
    Emojis.volcano: Emojis.rock,
  };
}