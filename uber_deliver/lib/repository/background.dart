import 'dart:convert';
import 'dart:math';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:uber_deliver/cubits/service_cubit.dart';
import 'package:uber_deliver/repository/gps.dart';
import 'package:uber_deliver/repository/server.dart';

import '../main.dart';
import '../models/delivery_request.dart';
import '../models/order.dart';
import 'cache.dart';
import 'direction.dart';
import 'messages_remote.dart';
import 'notifications.dart';

abstract class BackgroundIDs {
  static int availability = 1;
  static int running = 2;
}

abstract class Backgrounds {
  static Future<void> init() async {
    await AndroidAlarmManager.initialize();
  }

  static Future<void> stopAvailability() async {
    await AndroidAlarmManager.cancel(BackgroundIDs.availability);
  }

  static Future<void> schedulerAvailability() async {
    await AndroidAlarmManager.periodic(
      Duration(minutes: 5),
      exact: true,
      wakeup: true,
      allowWhileIdle: true,
      startAt: DateTime.now().add(Duration(seconds: 1)),
      BackgroundIDs.availability,
      available,
    );
  }

  static Future<void> schedulerRunning() async {
    await AndroidAlarmManager.periodic(
      Duration(minutes: 1),
      rescheduleOnReboot: true,
      allowWhileIdle: true,
      wakeup: true,
      exact: true,
      startAt: DateTime.now().add(Duration(seconds: 10)),
      BackgroundIDs.running,
      running,
    );
  }

  static Future<void> stopRunning() async {
    await AndroidAlarmManager.cancel(BackgroundIDs.running);
  }

  @pragma('vm:entry-point')
  static void running() async {
    await Cache.init();
    await Server.init();

    print("going to get the GPS");

    final request = Cache.runningRequest;

    if (request == null || request.order.expired) {
      // todo show notification in case the order is expired
      await AwesomeNotifications().cancelAll();
      await Backgrounds.stopRunning();
      Cache.runningRequest = null;
      return;
    }

    // get gps location
    final location = await GpsRepository.getLocation(goThrough: true);

    print(location);
    if (location == null) return;

    Cache.trackingLocation = location;

    final deliveryManID = Server.auth.currentUser!.uid;
    final alreadyFromSeller = Cache.trackedToSeller == null
        ? false
        : Cache.trackedToSeller!.difference(DateTime.now()).inHours < 3;

    final updatedTrack = await Server().pushTrack(
        request.order.toTrack(deliveryManID, location, alreadyFromSeller));

    if (updatedTrack.toSeller == true && alreadyFromSeller) {
      Cache.trackedToSeller = DateTime.now();
    } else if (updatedTrack.toSeller != true) {
      Cache.trackedToSeller = null;
    }

    print("Hello Running");
    // send request to api
    // get location to seller + client
    // update the notification (action buttons, photo, qr code, etc..)

    // scheduler notification for rating!!
  }

  @pragma('vm:entry-point')
  static Future<void> firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    await Cache.init();

    if (message.data.containsKey("type") &&
        message.data["type"] == "orderAccepted") {
      final myLocation = Cache.availabilityLocation;
      if (myLocation == null) {
        await AwesomeNotifications().cancelAll();
        return;
      }

      await ServiceCubit.handleAcceptedOrderNoti(message, myLocation);
    }

    print("Handling a background message: ${message.messageId}");
  }

  @pragma('vm:entry-point')
  static void available() async {
    await Cache.init();
    await Server.init();

    final location = await GpsRepository.getLocation(goThrough: true);
    if (location == null) return Future.value(false);

    final cell = DirectionRepository.roundToSquareCenter(
        location.longitude, location.latitude, 30);

    final cellID = "zone-${cell.dx}-${cell.dy}";

    if (Cache.attachedCells.contains(cellID)) {
      // finish this task!
      // return Future.value(true);
    } else {
      await RemoteMessages().unattachFromCells(Cache.attachedCells);
      await RemoteMessages().attachToCell(cellID);
      Cache.attachedCells = [cellID];

      final newCity = await DirectionRepository.getCityName(location);
      await Notifications.available(city: newCity);
    }
  }
}
