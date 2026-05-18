import 'package:grimoji/config/emojis.dart';
import 'package:grimoji/config/levels/game_level.dart';

enum LevelType { puzzle, arcade }

const List<GameLevel> gameLevels = [
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
      // Emojis.leafyGreen,
      Emojis.fire,
      // Emojis.sunWithFace,
      // Emojis.herb,
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
        skipAutoPlayer: true,

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
