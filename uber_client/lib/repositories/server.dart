import 'dart:async';
import 'dart:convert';

import 'package:bsahtak/models/clientSubmit.dart';
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
    baseUrl: "https://wastnothin.vercel.app/api/",
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

    // sometime it's called mutliple times (7times!), so we need to force it to be called once
    bool isGood = false;

    final sub = auth.authStateChanges().listen((event) async {
      if (event == null) {
        listen(null);
      } else {
        print("Auth changed" + Timestamp.now().toDate().toIso8601String());
        if (isGood) return;
        isGood = true;

        final idToken = await event.getIdTokenResult(
          forced == false && forceFirst,
        ); //todo this call cause the listener to fire again, why not return empty and later if isGood return the good client!

        injectToken(idToken.token!);
        final role = idToken.claims?["role"] ?? "";
        forced = true;

        listen(Client(
          id: event.uid,
          name: event.displayName ?? "",
          phone: event.phoneNumber ?? idToken.claims?["phone_number"] ?? "",
          photo: event.photoURL ??
              "https://api.dicebear.com/6.x/identicon/svg?seed=${event.phoneNumber}",
          isActive: role == "client",
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
    try {
      final response = await http.get("map/$x,$y,30");
      final data = response.data["foods"] as List<dynamic>;

      return data.map((e) => Bag.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> Function() listenToZone(
      String zoneID, Function(Map<String, dynamic>) callback) {
    final ref = firestore.collection("zones").doc(zoneID);

    final sub = ref.snapshots().listen((event) {
      if (event.exists) callback(event.data()!);
    });

    return sub.cancel;
  }

  Future<void> Function() listenToOrder(
      String orderID, Function(Order) callback) {
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

  Future<void> Function() listenToPrevOrders(
      DateTime lastUpdate, void Function(List<Order>) listen) {
    final query = firestore
        .collection("orders")
        .where("clientID", isEqualTo: auth.currentUser!.uid)
        .where("lastUpdate", isGreaterThan: Timestamp.fromDate(lastUpdate));

    final stream = query.snapshots().listen((event) {
      final List<Order> changes = [];

      event.docChanges.forEach((change) {
        if (change.type == DocumentChangeType.removed) return;

        final doc = change.doc.data();

        changes.add(Order.fromJson(
          FirestoreUtils.goodJson(
            {...doc!, "id": change.doc.id},
          ),
        ));
      });

      listen(changes);
    });

    return stream.cancel;
  }

  Future<void> rate({
    required String orderID,
    required int rating,
  }) async {
    final response = await http.post(
      "order/rate",
      data: {
        "orderID": orderID,
        "rating": rating,
        "clientID": auth.currentUser!.uid,
      },
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to rate");
    }
  }

  Future<void> submitClient(String clientID, ClientSubmit client) async {
    await Future.wait([
      firestore.collection('clients').doc(clientID).set({
        ...client.toJson(),
        'active': false,
        'suspended': false,
      }, SetOptions(merge: true)),
      http.post("submitting/client"),
      auth.currentUser!.updateDisplayName(client.name),
    ]);

    auth.currentUser!.reload();
    // update the user account!
  }

  Future<List<Ad>> getAds() async {
    try {
      final response = await http.get("ads");
      final data = response.data["ads"] as List<dynamic>;

      return data.map((e) => Ad.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }
}
