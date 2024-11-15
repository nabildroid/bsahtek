import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:store/cubits/app_cubit.dart';
import 'package:store/model/seller.dart';

import '../cubits/home_cubit.dart';
import '../repository/cache.dart';
import '../repository/server.dart';
import 'home.dart';
import 'login_screen.dart';

/** THIS widget will be under the login one, and replaced only by the Home */
class LoadingToHomeScreen extends StatefulWidget {
  final Seller? user;
  const LoadingToHomeScreen({super.key, this.user});

  @override
  State<LoadingToHomeScreen> createState() => _LoadingToHomeScreenState();
}

class _LoadingToHomeScreenState extends State<LoadingToHomeScreen> {
  bool loaded = false;

  @override
  void initState() {
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
    final isAlreadyActivated = Cache.seller?.isActive == true;
    if (isAlreadyActivated) {
      await context.read<AppCubit>().setUser(Cache.seller!);
      await Server().setupTokenization();
      context.go("/home");
    } else {
      await Future.delayed(Duration(milliseconds: 1500));
      // either it doesn't exist or it's not activated, both cases we need to login
      // the login need to pop it self after success login, or tokenRefreched is Activated
      // login handle it all

      final delivery = await Navigator.of(context).push(
        LoginScreen.go(),
      ) as Seller;

      await Server().setupTokenization(alreadyInited: true);
      await context.read<AppCubit>().setUser(delivery);
      context.go("/home");
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
                  colorFilter:
                      ColorFilter.mode(Colors.green, BlendMode.srcATop),
                  child: Image.network(
                    'https://bsahtek.net/static/logo.png',
                  ), //
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
