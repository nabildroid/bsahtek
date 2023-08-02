import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:deliver/cubits/app_cubit.dart';
import 'package:deliver/models/delivery_man.dart';
import 'package:deliver/repository/cache.dart';
import 'package:deliver/repository/server.dart';

import 'home.dart';
import 'login.dart';

/** THIS widget will be under the login one, and replaced only by the Home */
class LoadingToHomeScreen extends StatefulWidget {
  final DeliveryMan? user;
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
    final isAlreadyActivated = Cache.deliveryMan?.isActive == true;
    if (isAlreadyActivated) {
      await context.read<AppCubit>().setUser(Cache.deliveryMan!);
      await Server().setupTokenization();
      context.go("/home");
    } else {
      // either it doesn't exist or it's not activated, both cases we need to login
      // the login need to pop it self after success login, or tokenRefreched is Activated
      // login handle it all

      final delivery = await Navigator.of(context).push(
        LoginScreen.go(),
      ) as DeliveryMan;

      await Server().setupTokenization(alreadyInited: true);
      await context.read<AppCubit>().setUser(delivery);
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
