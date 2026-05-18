import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:grimoji/config/routes.dart';
import 'package:grimoji/features/grimoire/screen.dart';

import 'package:grimoji/features/main_menu.dart';
import 'package:grimoji/features/map/screen.dart';
import 'package:grimoji/features/level/fail_screen/screen.dart';
import 'package:grimoji/features/level/hint_screen/screen.dart';
import 'package:grimoji/features/settings/screen.dart';
import 'package:grimoji/widgets/layout_scaffold.dart';

import 'package:grimoji/features/level/screen.dart';
import 'package:grimoji/features/level/win_screen/screen.dart';
import 'package:grimoji/config/levels/index.dart';

final _routerNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

final router = GoRouter(
  navigatorKey: _routerNavigatorKey,
  initialLocation: Routes.homeRoute,
  // redirect: (BuildContext context, GoRouterState state) {
  //   return '/map/play/2';
  // },
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          LayoutScaffold(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.mapRoute,
              name: Routes.map,
              builder: (context, state) {
                final autoOpenStr = state.uri.queryParameters['autoOpen'];
                final autoOpenInt = autoOpenStr != null
                    ? int.tryParse(autoOpenStr)
                    : null;
                return LevelsMapScreen(autoOpenLevel: autoOpenInt);
              },
            ),
          ],
        ),

        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.grimoireRoute,
              name: Routes.grimoire,
              builder: (context, state) => GrimoireScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.cauldronRoute,
              name: Routes.cauldron,
              builder: (context, state) =>
                  const Scaffold(body: Center(child: Text("Cauldron"))),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.covenRoute,
              name: Routes.coven,
              builder: (context, state) =>
                  const Scaffold(body: Center(child: Text("Coven"))),
            ),
          ],
        ),

        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.marketRoute,
              name: Routes.market,
              builder: (context, state) =>
                  const Scaffold(body: Center(child: Text("Market"))),
            ),
          ],
        ),
      ],
    ),

    GoRoute(
      parentNavigatorKey: _routerNavigatorKey,
      path: Routes.homeRoute,
      name: Routes.home,
      builder: (context, state) => const MainMenuScreen(),
    ),

    GoRoute(
      parentNavigatorKey: _routerNavigatorKey,
      path: Routes.settingsRoute,
      name: Routes.settings,
      builder: (context, state) => const SettingsScreen(),
    ),

    GoRoute(
      parentNavigatorKey: _routerNavigatorKey,
      path: Routes.levelHintRoute,
      name: Routes.levelHint,
      builder: (context, state) {
        final level = int.parse(state.pathParameters['level']!);
        return LevelHintScreen(level: level);
      },
    ),

    GoRoute(
      parentNavigatorKey: _routerNavigatorKey,
      path: Routes.levelPlayRoute,
      name: Routes.levelPlay,
      builder: (context, state) {
        final levelNumber = int.parse(state.pathParameters['level']!);
        final level = gameLevels.singleWhere((e) => e.number == levelNumber);
        return LevelScreen(level: level);
      },
    ),

    GoRoute(
      parentNavigatorKey: _routerNavigatorKey,
      path: Routes.levelWonRoute,
      name: Routes.levelWon,
      builder: (context, state) {
        final map = state.extra as Map<String, dynamic>?;
        final stars = map?['stars'] as int;
        final level = map?['level'] as int;
        return WinGameScreen(stars: stars, level: level);
      },
    ),

    GoRoute(
      parentNavigatorKey: _routerNavigatorKey,
      path: Routes.levelFailRoute,
      name: Routes.levelFail,
      builder: (context, state) {
        final level = int.parse(state.pathParameters['level']!);
        return LevelFailScreen(level: level);
      },
    ),
  ],
);
