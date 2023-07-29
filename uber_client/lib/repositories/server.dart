import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../models/bag.dart';
import '../models/client.dart';
import '../models/order.dart';
import '../models/tracking.dart';
import '../utils/firebase.dart';

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
    // await auth.signOut();
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

  VoidCallback onUserChange(Function(Client?) listen,
      {bool forceFirst = false}) {
    bool forced = false;
    final sub = auth.authStateChanges().listen((event) async {
      if (event == null) {
        listen(null);
      } else {
        listen(Client(
          id: event.uid,
          name: event.displayName ?? "",
          phone: event.phoneNumber ?? "",
          photo: event.photoURL ??
              "https://api.dicebear.com/6.x/identicon/svg?seed=${event.phoneNumber}",
        ));
      }
    });

    return sub.cancel;
  }

  Future<void> assignNotiIDtoClient({
    String? clientID,
    String? notiID,
  }) async {
    return firestore.collection('clients').doc(clientID).set({
      'notiID': notiID,
    }, SetOptions(merge: true));
  }

  Future<void> orderBag(Order order) async {
    final data = order.toJson() as Map<String, dynamic>;
    data.remove("id");
    data.remove("sellerPhone");
    data.remove("sellerAddress");

    final response = await http.post(
      "order",
      data: jsonEncode(data),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to order bag");
    }
  }

  void Function() listenToTrack(
      Order order, Function(Tracking track) callback) {
    final sub = firestore
        .collection("tracks")
        .doc(order.id)
        .snapshots()
        .listen((event) {
      if (event.exists) {
        final track = Tracking.fromMap(FirestoreUtils.goodJson({
          "id": event.id,
          ...event.data()!,
        }));
        callback(track);
      }
    });

    return sub.cancel;
  }

  Future<List<Bag>> getBagsInCell(int x, int y) async {
    final response = await http.get("map/$x,$y,30");
    final data = response.data["foods"] as List<dynamic>;

    return data.map((e) => Bag.fromJson(e)).toList();
  }

  VoidCallback listenToZone(
      String zoneID, Function(Map<String, dynamic>) callback) {
    final ref = firestore.collection("zones").doc(zoneID);

    final sub = ref.snapshots().listen((event) {
      if (event.exists) callback(event.data()!);
    });

    return sub.cancel;
  }

  VoidCallback listenToOrder(String orderID, Function(Order) callback) {
    final ref = firestore.collection("orders").doc(orderID);

    final sub = ref.snapshots().listen((event) {
      if (event.exists) {
        final data = FirestoreUtils.goodJson(event.data()!);

        callback(Order.fromJson({
          "id": event.id,
          ...data,
        }));
      }
    });

    return sub.cancel;
  }

  List<Order> fetchPrevOrders(DateTime lastUpdate) {
    // todo
    return [];
  }
}
