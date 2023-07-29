import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uber_client/models/client.dart';

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
  @override
  void initState() {
    super.initState();

    // post frame to avoid the error of pushReplacement while the widget is building
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      init();
    });
  }

  void init() async {
    final isAlreadyLogin = Cache.client != null;
    if (isAlreadyLogin) {
      await context.read<AppCubit>().setUser(Cache.client!);
      await Server().setupTokenization();
      context.go("/home");
    } else {
      final client = await Navigator.of(context).push(
        LoginScreen.go(),
      ) as Client;

      await Server().setupTokenization(alreadyInited: true);
      await context.read<AppCubit>().setUser(client);
      context.go("/home");
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
