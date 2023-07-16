import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uber_client/cubits/app_cubit.dart';
import 'package:uber_client/cubits/bags_cubit.dart';
import 'package:uber_client/repositories/bags_remote.dart';
import 'package:uber_client/repositories/cache.dart';
import 'package:uber_client/repositories/gps.dart';
import 'package:uber_client/repositories/messages_remote.dart';
import 'package:uber_client/repositories/server.dart';
import 'package:uber_client/screens/home.dart';
import 'package:uber_client/screens/loading_screen.dart';
import 'package:uber_client/screens/login.dart';
import 'package:uber_client/screens/splash.dart';

import 'repositories/notifications.dart';
import 'screens/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
    final gpsRepository = GpsRepository();
    final bagRemote = BagRemote();
    final isLogin = Cache.isLogin;

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => BagsQubit(gpsRepository, bagRemote),
        ),
        BlocProvider(
          create: (_) => AppCubit(
            remoteMessages: RemoteMessages(),
          ),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Uber Clone',
        theme: ThemeData(
          primarySwatch: Colors.green,
        ),
        home: isLogin ? const LoadingScreen() : const Login(),
      ),
    );
  }
}
