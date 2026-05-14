import 'package:grimoji/config/emojis.dart';

enum ReactionType { 
  explosive,
  freezing,
  burning,
}

class Reaction{
  final ReactionType type;
  // when reaction type happens,emoji X transforms into emoji Y
  final Map<GameEmoji, GameEmoji> reactions;

  Reaction(this.type, this.reactions);
}