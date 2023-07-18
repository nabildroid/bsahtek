import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import "package:http/http.dart" as Http;
import 'package:latlong2/latlong.dart';
import 'package:uber_deliver/models/delivery_man.dart';

import '../models/order.dart';
import '../models/track.dart';
import '../utils/utils.dart';

final endpoint =
    (String path) => Uri.parse("http://192.168.0.105:3000/api/$path");

class Server {
  static late FirebaseFirestore firestore;

  static Future<void> init() async {
    await Firebase.initializeApp();
    firestore = FirebaseFirestore.instance;
  }

  Server();

  Future<DeliveryMan?> getDeliveryMan(String userID) {
    return firestore.collection('delivertMan').doc(userID).get().then((doc) {
      if (doc.exists) {
        final data = doc.data();
        return DeliveryMan(
          id: userID,
          name: data?['name'] ?? "Nabil",
          phone: data?['phone'] ?? "+2136565652",
          photo: "https://i.pravatar.cc/150?img=3",
        );
      } else {
        return null;
      }
    });
  }

  Future<void> assignNotiIDtoDeliveryMan(
      String deliveryManID, String notiID) async {
    return firestore.collection('deliveryman').doc(deliveryManID).set({
      'notiID': notiID,
    }, SetOptions(merge: true));
  }

  Future<void Function()> listenToOrder(
      String orderID, void Function(Order) onOrder) async {
    final stream = firestore.collection('orders').doc(orderID).snapshots();
    final sub = stream.listen((event) {
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

    await Http.post(
      endpoint("order/delivery/start"),
      body: jsonEncode(updatedOrder.toJson()),
      headers: {
        "Content-Type": "application/json",
      },
    );
  }

  Future<void> pushTrack(Track track) async {
    await Http.post(
      endpoint("order/delivery/track"),
      body: jsonEncode(track.toJson()),
      headers: {
        "Content-Type": "application/json",
      },
    );
  }
}
