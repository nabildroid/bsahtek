import 'dart:convert';
import 'dart:math';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:uber_client/repositories/server.dart';

import '../models/order.dart';
import '../utils/firebase.dart';
import 'cache.dart';
import 'direction.dart';
import 'messages_remote.dart';
import 'notifications.dart';

abstract class BackgroundIDs {
  static int availability = 1;
  static int running = 2;
}

abstract class Backgrounds {
  /**
   * return `false` if order is expired or something bad happened
   */
  @pragma('vm:entry-point')
  static Future<bool> firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    await Cache.init();
    await Server.init();

    if (!message.data.containsKey("type")) return false;

    final type = message.data["type"];

    if (type == "delivery_start") {
      var order = Order.fromJson(jsonDecode(message.data["order"]));
      if (order.expired)
        return false; // todo remove the notification, and log to the server

      await Notifications.deliveryOnProgress(order.deliveryName!);
      Cache.runningOrder = order;
      return true;
    }

    if (type == "delivery_end") {
      await Notifications.deliveryEnd();
      Cache.runningOrder = null;
      return true;
    }

    if (type == "order_accepted") {
      var order = Order.fromJson(jsonDecode(message.data["order"]));
      if (order.expired) return false; // todo remove the notification

      Cache.runningOrder = order;
      await Notifications.orderAccepted(order.isPickup);

      return true;
    }

    if (message.data["type"] == "delivery_end") {
      await Notifications.deliveryEnd();
      Cache.runningOrder = null;

      return true;
    }

    return true;
  }
}
