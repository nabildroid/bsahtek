// private navigators
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:uber_client/screens/favorit.dart';
import 'package:uber_client/screens/home.dart';
import 'package:uber_client/screens/loading_to_home.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorAKey = GlobalKey<NavigatorState>(debugLabel: 'shellA');
final _shellNavigatorBKey = GlobalKey<NavigatorState>(debugLabel: 'shellB');

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

    // Stateful nested navigation based on:
    // https://github.com/flutter/packages/blob/main/packages/go_router/example/lib/stateful_shell_route.dart
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        // the UI shell
        return ScaffoldWithNestedNavigation(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          navigatorKey: _shellNavigatorAKey,
          routes: [
            // top route inside branch
            GoRoute(
              path: '/home',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: HomeScreen(),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorBKey,
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
      // A common pattern when using bottom navigation bars is to support
      // navigating to the initial location when tapping the item that is
      // already active. This example demonstrates how to support this behavior,
      // using the initialLocation parameter of goBranch.
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        destinations: const [
          NavigationDestination(label: 'Home', icon: Icon(Icons.home)),
          NavigationDestination(label: 'Favort', icon: Icon(Icons.favorite)),
        ],
        onDestinationSelected: _goBranch,
      ),
    );
  }
}
