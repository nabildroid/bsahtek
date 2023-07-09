import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uber_seller/cubits/app_cubit.dart';
import 'package:uber_seller/screens/home.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AppQubit, AppState>(
      listener: (ctx, s) {
        if (s.user != null) {
          Navigator.of(ctx).pushReplacement(MaterialPageRoute(builder: (_) {
            return HomeScreen();
          }));
        }
      },
      listenWhen: (o, n) {
        return o.user == null && n.user != null;
      },
      child: const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
