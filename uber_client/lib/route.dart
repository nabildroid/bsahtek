// private navigators
import 'package:bsahtak/screens/filters.dart';
import 'package:bsahtak/screens/location_selector.dart';
import 'package:bsahtak/screens/offline.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:bsahtak/screens/discover.dart';
import 'package:bsahtak/screens/favorit.dart';
import 'package:bsahtak/screens/home.dart';
import 'package:bsahtak/screens/loading_to_home.dart';
import 'package:bsahtak/screens/me/account_setting_screen.dart';
import 'package:bsahtak/screens/me/me_screen.dart';
import 'package:bsahtak/screens/me/setting_screen.dart';
import 'package:bsahtak/screens/me/term.dart';

import 'cubits/bags_cubit.dart';
import 'cubits/home_cubit.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

// the one and only GoRouter instance
final goRouter = GoRouter(
  initialLocation: '/loading',
  navigatorKey: _rootNavigatorKey,
  routes: [
    GoRoute(
      path: '/loading',
      pageBuilder: (context, state) => const NoTransitionPage(
        child: LoadingToHomeScreen(),
      ),
    ),
    GoRoute(
      path: '/offline',
      pageBuilder: (context, state) => const NoTransitionPage(
        child: OfflineScreen(),
      ),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        // the UI shell
        return MultiBlocProvider(
          key: Key("Prov"),
          providers: [
            BlocProvider(create: (_) => BagsQubit()),
            BlocProvider(create: (_) => HomeCubit()),
          ],
          child: ScaffoldWithNestedNavigation(navigationShell: navigationShell),
        );
      },
      branches: [
        StatefulShellBranch(
          initialLocation: "/discover",
          routes: [
            // top route inside branch
            GoRoute(
                path: '/discover',
                pageBuilder: (context, state) => const MaterialPage(
                      child: DiscoverScreen(),
                    ),
                routes: [
                  GoRoute(
                    path: 'filters',
                    pageBuilder: (context, state) => CupertinoPage(
                      child: Filters(),
                      fullscreenDialog: true,
                    ),
                  ),
                  GoRoute(
                    path: 'location-picker',
                    pageBuilder: (context, state) => CupertinoPage(
                      child: LocationSelector(),
                      fullscreenDialog: true,
                    ),
                  ),
                ]),
          ],
        ),
        StatefulShellBranch(
          initialLocation: "/home",
          routes: [
            // top route inside branch
            GoRoute(
                path: '/home',
                pageBuilder: (context, state) => const MaterialPage(
                      child: HomeScreen(),
                    ),
                routes: [
                  GoRoute(
                    path: 'location-picker',
                    pageBuilder: (context, state) => CupertinoPage(
                      child: LocationSelector(),
                      fullscreenDialog: true,
                    ),
                  ),
                ]),
          ],
        ),
        StatefulShellBranch(
          routes: [
            // top route inside branch
            GoRoute(
              path: '/favorit',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: FavoritScreen(),
              ),
            ),
          ],
        ),
        // todo add more branch for my orders (success or expired!)
        StatefulShellBranch(
          initialLocation: "/me",
          routes: [
            // top route inside branch
            GoRoute(
                path: '/me',
                pageBuilder: (context, state) => const NoTransitionPage(
                      child: MeScreen(),
                    ),
                routes: [
                  GoRoute(
                      path: 'settings',
                      pageBuilder: (context, state) => const NoTransitionPage(
                            child: SettingScreen(),
                          ),
                      routes: [
                        GoRoute(
                          path: 'account',
                          pageBuilder: (context, state) =>
                              const NoTransitionPage(
                            child: AccountSettingScreen(),
                          ),
                        ),
                      ])
                ]),
          ],
        ),
      ],
    ),
  ],
);

class ScaffoldWithNestedNavigation extends StatelessWidget {
  const ScaffoldWithNestedNavigation({
    Key? key,
    required this.navigationShell,
  }) : super(key: key ?? const ValueKey('ScaffoldWithNestedNavigation'));
  final StatefulNavigationShell navigationShell;

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index != navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDialog = goRouter.location.endsWith("/filters") ||
        goRouter.location.endsWith("/location-picker");

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: isDialog
          ? null
          : NavigationBar(
              height: 64,
              backgroundColor: Colors.white,
              selectedIndex: navigationShell.currentIndex,
              elevation: 10,
              destinations: const [
                NavigationDestination(
                    label: 'Discover', icon: Icon(Icons.explore)),
                NavigationDestination(label: 'Home', icon: Icon(Icons.home)),
                NavigationDestination(
                    label: 'Favorite', icon: Icon(Icons.favorite)),
                NavigationDestination(
                    label: 'Me', icon: Icon(Icons.person_pin)),
              ],
              onDestinationSelected: _goBranch,
            ),
    );
  }
}
