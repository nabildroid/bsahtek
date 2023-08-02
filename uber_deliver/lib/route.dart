// private navigators
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:deliver/screens/home.dart';
import 'package:deliver/screens/loading_to_home.dart';
import 'package:deliver/screens/me/account_setting_screen.dart';
import 'package:deliver/screens/me/me_screen.dart';
import 'package:deliver/screens/me/setting_screen.dart';

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
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        // the UI shell
        return ScaffoldWithNestedNavigation(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            // top route inside branch
            GoRoute(
              path: '/home',
              pageBuilder: (context, state) => NoTransitionPage(
                child: HomeScreen(),
              ),
            ),
          ],
        ),

        // todo add more branch for my orders (success or expired!)
        StatefulShellBranch(
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
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        height: 64,
        backgroundColor: Colors.white,
        selectedIndex: navigationShell.currentIndex,
        elevation: 10,
        destinations: const [
          NavigationDestination(label: 'Home', icon: Icon(Icons.home)),
          NavigationDestination(label: 'Me', icon: Icon(Icons.person_pin)),
        ],
        onDestinationSelected: _goBranch,
      ),
    );
  }
}
