import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:deliver/cubits/app_cubit.dart';
import 'package:deliver/cubits/service_cubit.dart';
import 'package:deliver/repository/background.dart';
import 'package:deliver/repository/cache.dart';
import 'package:deliver/repository/direction.dart';
import 'package:deliver/repository/gps.dart';
import 'package:deliver/repository/messages_remote.dart';
import 'package:deliver/repository/notifications.dart';
import 'package:deliver/repository/server.dart';
import 'package:deliver/route.dart';
import 'package:deliver/screens/loading_to_home.dart';
import 'package:deliver/screens/login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Backgrounds.init();
  await Cache.init();
  await Notifications.createChannels();
  await Server.init();
  await RemoteMessages().initMessages();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (ctx) => AppCubit()),
        BlocProvider(create: (ctx) => ServiceCubit()),
      ],
      child: MaterialApp.router(
        routerConfig: goRouter,
        title: 'bsahtac Deliver',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.green,
        ),
      ),
    );
  }
}
