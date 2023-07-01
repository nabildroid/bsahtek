import 'package:go_router/go_router.dart';

/// The route configuration.
final GoRouter routerConfig = GoRouter(
  initialLocation: "/home",
  routes: <RouteBase>[
    GoRoute(
      path: '/home',
    ),
  ],
);
