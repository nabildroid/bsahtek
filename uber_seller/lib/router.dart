import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uber_seller/cubits/app_cubit.dart';
import 'package:uber_seller/repository/cache.dart';
import 'package:uber_seller/repository/messages_remote.dart';
import 'package:uber_seller/repository/server.dart';
import 'package:uber_seller/screens/Loading.dart';
import 'package:uber_seller/screens/home.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final Completer _initCompleter = Completer<bool>();

late final Cache _cache;
late final RemoteMessages _remoteMessages;

bool called = false;
Future<void> _lazyInitApp() async {
  if (called) return;
  called = true;

  _cache = Cache(await SharedPreferences.getInstance());
  await Server.init();
  _remoteMessages = RemoteMessages();

  _initCompleter.complete(true);
}

bool isMainQubitInited = false;

final AppRouter = GoRouter(
  initialLocation: "/loading",
  routes: [
    GoRoute(
      path: "/headless/:id",
      builder: (context, state) {
        _lazyInitApp();
        return Scaffold(
            body: Center(
          child: TextButton(
            onPressed: () {
              context.go("/home");
            },
            child: Text("Init"),
          ),
        ));
      },
    ),

    GoRoute(path: "/", redirect: (context, state) => "/loading", routes: [
      ShellRoute(
          navigatorKey: _rootNavigatorKey,
          builder: (ctx, state, child) {
            _lazyInitApp();

            return child;
          },
          routes: [
            GoRoute(
              path: 'loading',
              pageBuilder: (context, state) => MaterialPage<void>(
                key: state.pageKey,
                child: LoadingScreen(_initCompleter.future, (context) async {
                  if (!isMainQubitInited) {
                    isMainQubitInited = true;
                    context.read<AppQubit>().init(
                          cache: _cache,
                          remoteMessages: _remoteMessages,
                        );
                  }
                }),
              ),
            ),
            GoRoute(
              path: 'home',
              redirect: (context, state) =>
                  !_initCompleter.isCompleted ? "/loading" : null,
              pageBuilder: (context, state) => MaterialPage<void>(
                key: state.pageKey,
                child: HomeScreen(),
              ),
            ),
          ]),
    ])

    // define other routes as needed
  ],
);
