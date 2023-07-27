import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uber_client/cubits/app_cubit.dart';
import 'package:uber_client/cubits/bags_cubit.dart';
import 'package:uber_client/cubits/home_cubit.dart';
import 'package:uber_client/repositories/cache.dart';
import 'package:uber_client/repositories/messages_remote.dart';
import 'package:uber_client/repositories/server.dart';
import 'package:uber_client/screens/loading_to_home.dart';

import 'repositories/notifications.dart';

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
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => BagsQubit()),
        BlocProvider(create: (_) => HomeCubit()),
        BlocProvider(create: (_) => AppCubit()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Uber Clone',
        theme: ThemeData(
          primarySwatch: Colors.green,
        ),
        home: const LoadingToHomeScreen(),
      ),
    );
  }
}
