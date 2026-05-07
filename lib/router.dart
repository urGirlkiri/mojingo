import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mojingo/config/routes.dart';

import 'package:mojingo/features/main_menu.dart';
import 'package:mojingo/features/map/screen.dart';
import 'package:mojingo/features/map/level_fail_screen.dart';
import 'package:mojingo/features/map/widgets/level_hint.dart';
import 'package:mojingo/features/settings/screen.dart';
import 'package:mojingo/widgets/layout_scaffold.dart';

import 'package:mojingo/features/game/play_screen.dart';
import 'package:mojingo/features/game/win_screen.dart';
import 'package:mojingo/features/game/logic/levels.dart'; 

final _routerNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

final router = GoRouter(
  navigatorKey: _routerNavigatorKey,
  initialLocation: Routes.home,
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          LayoutScaffold(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.levelsMap,
              builder: (context, state) {
                final autoOpenStr = state.uri.queryParameters['autoOpen'];
                final autoOpenInt = autoOpenStr != null
                    ? int.tryParse(autoOpenStr)
                    : null;
                return LevelsMapScreen(autoOpenLevel: autoOpenInt,);
              },
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.bounties,
              builder: (context, state) =>
                  const Scaffold(body: Center(child: Text("Recipes"))),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.friends,
              builder: (context, state) =>
                  const Scaffold(body: Center(child: Text("Friends"))),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.market,
              builder: (context, state) =>
                  const Scaffold(body: Center(child: Text("Market"))),
            ),
          ],
        ),
      ],
    ),

    GoRoute(
      parentNavigatorKey: _routerNavigatorKey,
      path: Routes.home,
      builder: (context, state) => const MainMenuScreen(),
    ),
    
    GoRoute(
      parentNavigatorKey: _routerNavigatorKey,
      path: Routes.settings,
      builder: (context, state) => const SettingsScreen(),
    ),
    
    GoRoute(
      parentNavigatorKey: _routerNavigatorKey,
      path: Routes.levelHint ,
      builder: (context, state) {
        final level = int.parse(state.pathParameters['level']!);
        return LevelHintScreen(level: level);
      },
    ),
    
    GoRoute(
      parentNavigatorKey: _routerNavigatorKey,
      path: Routes.levelPlay,
      builder: (context, state) {
        final levelNumber = int.parse(state.pathParameters['level']!);
        final level = gameLevels.singleWhere((e) => e.number == levelNumber);
        return LevelScreen(level);
      },
    ),
    
    GoRoute(
      parentNavigatorKey: _routerNavigatorKey,
      path: Routes.levelWon,
      builder: (context, state) {
        final map = state.extra as Map<String, dynamic>?;
        final stars = map?['stars'] as int; 
        final level = map?['level'] as int;
        return WinGameScreen(stars: stars, level: level);
      },
    ),
    
    GoRoute(
      parentNavigatorKey: _routerNavigatorKey,
      path: Routes.levelFail,
      builder: (context, state) {
        final level = int.parse(state.pathParameters['level']!);
        return LevelFailScreen(level: level);
      },
    ),
    
  ],
);