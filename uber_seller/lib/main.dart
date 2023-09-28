import 'dart:convert';
import 'dart:math';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'package:android_intent_plus/android_intent.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:receive_intent/receive_intent.dart';
import 'package:store/repository/cache.dart';
import 'package:store/repository/server.dart';
import 'package:store/router.dart';
import 'package:store/screens/Loading_to_home.dart';
import 'package:store/screens/running_order.dart';

import 'cubits/app_cubit.dart';
import 'cubits/home_cubit.dart';
import 'model/order.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // final intentData = await getIntentData();
  // if (intentData != null) {
  //   final order = Order.fromJson(jsonDecode(intentData));

  //   runApp(QuickRunningOrderApp(order));
  //   return;
  // }

  await Cache.init();

  await Server.init();

  if (kDebugMode == false) {
    FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };
    // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }

  runApp(MyApp());
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Cache.init();

  final order = Order.fromJson(jsonDecode(message.data["order"]));

  if (order.expired) {
    return;
  }

  await Cache.pushRunningOrder(order);

  if (false) {
    AndroidIntent intent = AndroidIntent(
      componentName: "me.laknabil.uber_seller.MyMainActivity",
      package: 'me.laknabil.uber_seller',
      data: jsonEncode(order.toJson()),
    );

    await intent.launch();
  }

  print("Handling a background message: ${message.messageId}");
}

Future<String?> getIntentData() async {
  try {
    final receivedIntent = await ReceiveIntent.getInitialIntent();
    return receivedIntent?.data;
  } on PlatformException {
    // Handle exception
  }
  return null;
}

class QuickRunningOrderApp extends StatelessWidget {
  final Order order;

  const QuickRunningOrderApp(this.order, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return MaterialApp(
      title: 'Quick Running Order',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: RunningOrder(
        order: order,
        index: 1,
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (ctx) => AppCubit()),
      ],
      child: MaterialApp.router(
        routerConfig: goRouter,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.green,
        ),
      ),
    );
  }
}
