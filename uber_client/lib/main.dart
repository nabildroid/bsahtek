import 'package:bsahtak/repositories/cache.dart';
import 'package:bsahtak/repositories/messages_remote.dart';
import 'package:bsahtak/repositories/server.dart';
import 'package:bsahtak/route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'cubits/app_cubit.dart';
import 'cubits/bags_cubit.dart';
import 'cubits/home_cubit.dart';
import 'repositories/notifications.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await Cache.init();
  await Server.init();
  await Notifications.createChannels();
  await RemoteMessages().initMessages();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => BagsQubit()),
        BlocProvider(create: (_) => HomeCubit()),
        BlocProvider(create: (_) => AppCubit()),
      ],
      child: MaterialApp.router(
        routerConfig: goRouter,
        debugShowCheckedModeBanner: false,
        title: 'Bsahtak',
        theme: ThemeData(
          primarySwatch: Colors.green,
        ),
      ),
    );
  }
}
