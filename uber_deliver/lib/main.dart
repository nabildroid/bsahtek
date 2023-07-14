import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import 'package:uber_deliver/cubits/app_cubit.dart';
import 'package:uber_deliver/cubits/service_cubit.dart';
import 'package:uber_deliver/repository/background.dart';
import 'package:uber_deliver/repository/cache.dart';
import 'package:uber_deliver/repository/direction.dart';
import 'package:uber_deliver/repository/gps.dart';
import 'package:uber_deliver/repository/messages_remote.dart';
import 'package:uber_deliver/repository/notifications.dart';
import 'package:uber_deliver/repository/server.dart';
import 'package:uber_deliver/screens/home.dart';
import 'package:uber_deliver/screens/loading.dart';
import 'package:uber_deliver/screens/running.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Cache.init();

  await Notifications.createChannels();
  await Server.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (ctx) => AppCubit()),
        BlocProvider(create: (ctx) => ServiceCubit()),
      ],
      child: MaterialApp(
        title: 'Uber Deliver',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.green,
        ),
        home: LoadingScreen(),
      ),
    );
  }
}
