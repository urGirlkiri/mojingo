import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mojingo/config/routes.dart';
import 'package:mojingo/features/main_menu.dart';
import 'package:mojingo/features/map/screen.dart';
import 'package:mojingo/features/settings/screen.dart';
import 'package:mojingo/widgets/layout_scaffold.dart';

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
              builder: (context, state) => const LevelsMapScreen(),
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
      path: Routes.settings,
      builder: (context, state) => const SettingsScreen(key: Key('settings')),
    ),
  ],
);
