import 'package:grimoji/config/emojis.dart';

enum LevelType { puzzle, arcade }

const gameLevels = [
  GameLevel(
    number: 1,
    timeLimit: 120,
    targetAmount: 3,
    targetEmoji: Emojis.ocean,
    availableEmojis: [
      Emojis.droplet,
      Emojis.leafyGreen,
      Emojis.sunWithFace,
      Emojis.bug,
    ],
    type: LevelType.puzzle,
    achievementIdIOS: 'lvl_1_ios',
    achievementIdAndroid: 'lvl_1_android',
  ),

  GameLevel(
    number: 2,
    timeLimit: 200,
    targetEmoji: Emojis.cloud,
    targetAmount: 2,
    availableEmojis: [
      Emojis.droplet,
      Emojis.leafyGreen,
      Emojis.sunWithFace,
      Emojis.herb,
      Emojis.mushroom,
    ],
    type: LevelType.puzzle,
  ),

  GameLevel(
    number: 3,
    timeLimit: 200,
    targetAmount: 3,
    targetEmoji: Emojis.bomb,
    availableEmojis: [
      Emojis.fire,
      Emojis.evergreenTree,
      Emojis.rock,
      Emojis.droplet,
      Emojis.leafyGreen,
    ],
    type: LevelType.puzzle,
  ),

  GameLevel(
    number: 4,
    timeLimit: 200,
    targetAmount: 5,
    targetEmoji: Emojis.bomb,
    availableEmojis: [
      Emojis.fire,
      Emojis.rock,
      Emojis.evergreenTree,
      Emojis.droplet,
      Emojis.frog,
      Emojis.octopus,
      Emojis.crab,
    ],
    type: LevelType.puzzle,
  ),

  GameLevel(
    number: 5,
    timeLimit: 1200,
    targetEmoji: Emojis.rainbow,
    targetAmount: 1,
    availableEmojis: [
      Emojis.droplet,
      Emojis.ocean,
      Emojis.cloud,
      Emojis.fire,
      Emojis.frog,
      Emojis.octopus,
      Emojis.crab,
    ],
    type: LevelType.puzzle,
    skipAutoPlayer: true,
    achievementIdIOS: 'finished',
    achievementIdAndroid: 'CdfIhE96aspNWLGSQg',
  ),
];

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
