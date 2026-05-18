import 'package:grimoji/config/emojis.dart';
import 'package:grimoji/config/levels/index.dart';

class GameLevel {
  final int number;
  final int targetAmount;
  final int timeLimit;
  final GameEmoji targetEmoji;
  final List<GameEmoji> availableEmojis;
  final LevelType type;
  final bool skipAutoPlayer;

  final String? achievementIdIOS;
  final String? achievementIdAndroid;

  bool get awardsAchievement => achievementIdAndroid != null;

  const GameLevel({
    required this.number,
    required this.targetAmount,
    required this.timeLimit,
    required this.targetEmoji,
    required this.availableEmojis,
    required this.type,
    this.skipAutoPlayer = false,
    this.achievementIdIOS,
    this.achievementIdAndroid,
  }) : assert(
         (achievementIdAndroid != null && achievementIdIOS != null) ||
             (achievementIdAndroid == null && achievementIdIOS == null),
         'Either both iOS and Android achievement ID must be provided, '
         'or none',
       );
}
