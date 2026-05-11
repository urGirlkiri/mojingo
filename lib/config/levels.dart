import 'package:grimoji/config/emojis.dart';

const gameLevels = [
  GameLevel(
    number: 1,
    timeLimit: 120,
    targetEmoji: Emojis.ocean,
    targetAmount: 3,
    availableEmojis: [
      Emojis.droplet,
      Emojis.leafyGreen,
      Emojis.sunWithFace,
      Emojis.mushroom,
      Emojis.bug,
    ],
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
    ],
  ),

  GameLevel(
    number: 3,
    timeLimit: 200,
    targetEmoji: Emojis.bomb,
    targetAmount: 3,
    availableEmojis: [
      Emojis.fire,
      Emojis.evergreenTree,
      Emojis.rock,
      Emojis.droplet,
      Emojis.leafyGreen,
    ],
  ),

  GameLevel(
    number: 4,
    timeLimit: 200,
    targetEmoji: Emojis.gemStone,
    targetAmount: 5,
    availableEmojis: [
      Emojis.fire,
      Emojis.rock,
      Emojis.bomb,
      Emojis.evergreenTree,
      Emojis.droplet,
    ],
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
      Emojis.alien,
      Emojis.robot,
      Emojis.ghost,
      Emojis.skull,
      Emojis.clown,
      Emojis.tRex,
      Emojis.foxFace,
      Emojis.cowFace,
      Emojis.pig,
      Emojis.frog,
      Emojis.octopus,
      Emojis.crab,
    ],
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

  final String? achievementIdIOS;
  final String? achievementIdAndroid;

  bool get awardsAchievement => achievementIdAndroid != null;

  const GameLevel({
    required this.number,
    required this.targetAmount,
    required this.timeLimit,
    required this.targetEmoji,
    required this.availableEmojis,
    this.achievementIdIOS,
    this.achievementIdAndroid,
  }) : assert(
         (achievementIdAndroid != null && achievementIdIOS != null) ||
             (achievementIdAndroid == null && achievementIdIOS == null),
         'Either both iOS and Android achievement ID must be provided, '
         'or none',
       );
}