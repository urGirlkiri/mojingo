import 'package:grimoji/config/emojis.dart';
import 'package:grimoji/features/alchemy/reactions/reaction.dart';

enum ActionType {
  placeEmoji,
  transmuteEmoji,
  doNothing,
}

class BehaviorAction {
  final ActionType type;
  final int x;
  final int y;
  final GameEmoji? emoji;

  const BehaviorAction({
    required this.type,
    required this.x,
    required this.y,
    this.emoji,
  });
}


abstract class EmojiBehavior {
  List<BehaviorAction> onTurnEnd(int x, int y) => [];

  List<BehaviorAction> onMatched(int x, int y) => [];

  List<BehaviorAction> onBlastNearby(int x, int y, ReactionType blastType) => [];

  List<BehaviorAction> onSwipedWith(int x, int y, GameEmoji targetEmoji) => [];
}