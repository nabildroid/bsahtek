import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uber_client/cubits/bags_cubit.dart';
import 'package:uber_client/repositories/bags_remote.dart';
import 'package:uber_client/repositories/gps.dart';
import 'package:uber_client/screens/home.dart';

import 'screens/home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final gpsRepository = GpsRepository();
    final bagRemote = BagRemote();

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => BagsQubit(gpsRepository, bagRemote)),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Uber Clone',
        theme: ThemeData(
          primarySwatch: Colors.green,
        ),
        home: const Home(),
      ),
    );
  }
}
