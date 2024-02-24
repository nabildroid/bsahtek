import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:bsahtak/models/client.dart';

import '../cubits/app_cubit.dart';
import '../repositories/cache.dart';
import '../repositories/server.dart';
import 'home.dart';
import 'login.dart';

/** THIS widget will be under the login one, and replaced only by the Home */
class LoadingToHomeScreen extends StatefulWidget {
  final Client? user;
  const LoadingToHomeScreen({super.key, this.user});

  @override
  State<LoadingToHomeScreen> createState() => _LoadingToHomeScreenState();
}

class _LoadingToHomeScreenState extends State<LoadingToHomeScreen> {
  bool loaded = false;

  @override
  void initState() {
    FlutterNativeSplash.remove();

    super.initState();

    setState(() {
      loaded = true;
    });

    // post frame to avoid the error of pushReplacement while the widget is building
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      init();
    });
  }

  void init() async {
    final isOnline = await Connectivity().checkConnectivity();
    if (isOnline == ConnectivityResult.none) {
      context.replace("/offline");
      return;
    }

    final isAlreadyLogin = Cache.client != null;
    if (isAlreadyLogin) {
      await context.read<AppCubit>().setUser(Cache.client!);
      try {
        await Server().setupTokenization();
        context.go("/discover");
      } catch (e) {
        context.read<AppCubit>().logOut(context);
        context.replace("/loading");
      }
    } else {
      await Future.delayed(Duration(milliseconds: 1500));
      final client = await Navigator.of(context).push(
        LoginScreen.go(),
      );

      if (client == null) {
        SystemNavigator.pop();
        return;
      } else if (!(client is Client)) {
        return init();
      }

      await Server().setupTokenization(alreadyInited: true);
      await context.read<AppCubit>().setUser(client);
      context.go("/discover");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedScale(
        duration: Duration(seconds: 1),
        scale: loaded == false ? 2 : 1,
        curve: Curves.easeInExpo,
        child: AnimatedOpacity(
          duration: Duration(seconds: 1),
          curve: Curves.easeInExpo,
          opacity: loaded == false ? 0 : 1,
          child: Center(
            child: Hero(
              tag: "Logo",
              child: SizedBox(
                width: 150,
                child: ColorFiltered(
                  colorFilter: ColorFilter.mode(
                      Theme.of(context).colorScheme.primary, BlendMode.srcATop),
                  child: Image.asset("assets/logo.png"),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
