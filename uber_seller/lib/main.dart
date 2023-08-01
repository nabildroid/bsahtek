import 'dart:convert';
import 'dart:math';

import 'package:android_intent_plus/android_intent.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:receive_intent/receive_intent.dart';
import 'package:uber_seller/repository/cache.dart';
import 'package:uber_seller/repository/server.dart';
import 'package:uber_seller/router.dart';
import 'package:uber_seller/screens/Loading_to_home.dart';
import 'package:uber_seller/screens/running_order.dart';

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

  runApp(MyApp());
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  Cache.init();

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
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (ctx) => AppCubit()),
        BlocProvider(create: (ctx) => HomeCubit()),
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
