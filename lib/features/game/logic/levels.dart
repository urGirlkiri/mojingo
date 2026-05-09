// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:grimoji/config/emojis.dart';

const gameLevels = [
  GameLevel(    number: 1, difficulty: 5,  maxMoves: 5,  targetEmoji: Emojis.cloud, 
    // TODO: When ready, change these achievement IDs.
    // You configure this in App Store Connect.
    achievementIdIOS: 'first_win',
    // You get this string when you configure an achievement in Play Console.
    achievementIdAndroid: 'NhkIwB69ejkMAOOLDb',
  ),
  GameLevel(number: 2, difficulty: 42, maxMoves: 1, targetEmoji: Emojis.fire),
  GameLevel(number: 3, difficulty: 100, maxMoves: 1, targetEmoji: Emojis.droplet,
    achievementIdIOS: 'finished',
    achievementIdAndroid: 'CdfIhE96aspNWLGSQg',
  ),
];

class GameLevel {
  final int number;

  final int difficulty;

  final int maxMoves;

  final GameEmoji targetEmoji;

  /// The achievement to unlock when the level is finished, if any.
  final String? achievementIdIOS;

  final String? achievementIdAndroid;

  bool get awardsAchievement => achievementIdAndroid != null;

  const GameLevel({
    required this.number,
    required this.difficulty,
    required this.maxMoves,
    required this.targetEmoji,
    this.achievementIdIOS,
    this.achievementIdAndroid,
  }) : assert(
         (achievementIdAndroid != null && achievementIdIOS != null) ||
             (achievementIdAndroid == null && achievementIdIOS == null),
         'Either both iOS and Android achievement ID must be provided, '
         'or none',
       );
}
