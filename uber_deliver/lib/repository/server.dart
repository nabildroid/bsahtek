import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:uber_deliver/models/delivery_man.dart';
import 'package:uber_deliver/repository/cache.dart';
import 'package:dio/dio.dart';

import '../models/deliverySubmit.dart';
import '../models/order.dart';
import '../models/track.dart';
import '../utils/utils.dart';

class Server {
  static late FirebaseFirestore firestore;
  static late FirebaseAuth auth;
  static Dio http = Dio(BaseOptions(
    baseUrl: "http://192.168.0.105:3000/api/",
  ));

  static Future<void> init() async {
    await Firebase.initializeApp();
    firestore = FirebaseFirestore.instance;
    auth = FirebaseAuth.instance;
  }

  Server();

  void injectToken(String token) {
    http.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        options.headers["authorization"] = "Bearer ${token}";
        return handler.next(options);
      },
    ));
  }

  Future<void> setupTokenization({bool alreadyInited = false}) async {
    // todo it should break when the user is disabled, not exists ...etc
    if (!alreadyInited) {
      final token = await auth.currentUser!.getIdToken();
      injectToken(token);
    }

    auth.idTokenChanges().listen((event) async {
      if (event == null) {
        http.interceptors.clear();
      } else {
        final token = await event.getIdToken();
        injectToken(token);
      }
    });
  }

  VoidCallback onUserChange(Function(DeliveryMan?) listen,
      {bool forceFirst = false}) {
    bool forced = false;
    final sub = auth.authStateChanges().listen((event) async {
      if (event == null) {
        listen(null);
      } else {
        // calling getIdTokenResult will force authStateChanges to be called again
        final idToken = await event.getIdTokenResult(
          forced == false && forceFirst,
        );

        injectToken(idToken.token!);
        final role = idToken.claims?["role"] ?? "";
        forced = true;

        listen(DeliveryMan.fromUser(
          event,
          role == "deliver",
        ));
      }
    });

    return sub.cancel;
  }

  Future<void> assignNotiIDtoDeliveryMan(
      String deliveryManID, String notiID) async {
    return firestore.collection('delivers').doc(deliveryManID).set({
      'notiID': notiID,
    }, SetOptions(merge: true));
  }

  Future<void Function()> listenToOrder(
      String orderID, void Function(Order) onOrder) async {
    print("listen to order ${orderID}");
    // todo add updatedAt where!
    final stream = firestore
        .collection('orders')
        .doc(orderID)
        .snapshots(includeMetadataChanges: true);

    final sub = stream.listen((event) {
      // event.
      if (event.exists == false) return;

      final items = Utils.goodFirestoreJson(event.data()!);
      final order = Order.fromJson({...items, 'id': event.id});

      onOrder(order);
    });

    return sub.cancel;
  }

  Future<void> setDeliver(
      DeliveryMan deliver, Order order, LatLng address) async {
    final updatedOrder = order.setDeliver(deliver, address);

    await firestore
        .collection('orders')
        .doc(order.id)
        .set(updatedOrder.toJson(), SetOptions(merge: true));

    await http.post(
      "order/delivery/start",
      data: jsonEncode(updatedOrder.toJson()),
    );
  }

  Future<void> pushTrack(Track track) async {
    await http.post(
      "order/delivery/track",
      data: jsonEncode(track.toJson()),
    );
  }

  Future<void> submitDelivery(
      String deliveryID, String phone, DeliverySubmit delivery) async {
    await Future.wait([
      firestore.collection('delivers').doc(deliveryID).set({
        ...delivery.toJson(),
        'active': false,
        'phone': phone,
      }),
      auth.currentUser!.updateDisplayName(delivery.name),
      auth.currentUser!.updatePhotoURL(delivery.photo),
    ]);

    auth.currentUser!.reload();
    // update the user account!I
  }
}
