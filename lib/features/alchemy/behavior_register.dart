import 'package:grimoji/config/emojis.dart';
import 'package:grimoji/features/alchemy/behaviors/behavior.dart';
import 'package:grimoji/features/alchemy/behaviors/virus.dart';
import 'package:grimoji/features/alchemy/behaviors/ghost.dart';
import 'package:grimoji/features/alchemy/behaviors/rainbow.dart';

class BehaviorRegister {
  static final Map<GameEmoji, EmojiBehavior Function()> _behaviors = {
    Emojis.bug: () => VirusBehavior(),
    Emojis.ghost: () => GhostBehavior(),
    Emojis.rainbow: () => RainbowBehavior(),
  };

  static EmojiBehavior? getBehaviorFor(GameEmoji emoji) {
    final builder = _behaviors[emoji];
    return builder != null ? builder() : null;
  }

  static bool hasBehavior(GameEmoji emoji) {
    return _behaviors.containsKey(emoji);
  }
}