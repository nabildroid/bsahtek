import 'dart:convert';
import 'dart:math';

import 'package:android_intent_plus/android_intent.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:receive_intent/receive_intent.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uber_seller/model/seller.dart';
import 'package:uber_seller/repository/cache.dart';
import 'package:uber_seller/repository/messages_remote.dart';
import 'package:uber_seller/repository/server.dart';
import 'package:uber_seller/screens/Loading.dart';
import 'package:uber_seller/screens/home.dart';
import 'package:uber_seller/screens/running_order.dart';
import 'package:url_launcher/url_launcher.dart';

import 'cubits/app_cubit.dart';
import 'model/order.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final intentData = await getIntentData();
  if (intentData != null) {
    final order = Order.fromJson(jsonDecode(intentData));

    runApp(QuickRunningOrderApp(order));
    return;
  }

  final cache = Cache(await SharedPreferences.getInstance());

  await Server.init();

  runApp(MyApp(
    cache: cache,
  ));
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  final Cache cache = Cache(await SharedPreferences.getInstance());

  final order = Order.fromJson(jsonDecode(message.data["order"]));
  await cache.pushRunningOrder(order);

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
  final Cache cache;
  const MyApp({super.key, required this.cache});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) => AppQubit(
        cache: cache,
        remoteMessages: RemoteMessages(),
      )..init(),
      child: MaterialApp(
        title: 'Uber Seller',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.green,
        ),
        home: const LoadingScreen(),
      ),
    );
  }
}
