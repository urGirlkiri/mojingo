import 'package:grimoji/config/emojis.dart';
import 'package:grimoji/features/alchemy/reactions/reaction.dart';

class NatureExplosions extends Reaction {
  NatureExplosions() : super(ReactionType.burning, _reactions);

  static const Map<GameEmoji, GameEmoji> _reactions = {
    Emojis.evergreenTree: Emojis.fire,
    Emojis.rock: Emojis.gemStone,
  };
}
