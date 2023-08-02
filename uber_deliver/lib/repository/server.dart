import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:deliver/models/delivery_man.dart';
import 'package:deliver/repository/cache.dart';
import 'package:dio/dio.dart';

import '../models/deliverySubmit.dart';
import '../models/order.dart';
import '../models/track.dart';
import '../utils/utils.dart';

class Server {
  static late FirebaseFirestore firestore;
  static late FirebaseAuth auth;
  static late FirebaseStorage storage;
  static Dio http = Dio(BaseOptions(
    baseUrl: "https://wastnothin.vercel.app/api/",
  ));

  static Future<void> init() async {
    await Firebase.initializeApp();
    firestore = FirebaseFirestore.instance;

    auth = FirebaseAuth.instance;
    storage = FirebaseStorage.instance;
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
    // sometime it's called mutliple times (7times!), so we need to force it to be called once
    bool isGood = false;
    final sub = auth.authStateChanges().listen((event) async {
      if (event == null || event.phoneNumber == null) {
        listen(null);
      } else {
        print("Auth changed" + Timestamp.now().toDate().toIso8601String());
        if (isGood) return;
        isGood = true;
        // calling getIdTokenResult will force authStateChanges to be called again
        final idToken = await event.getIdTokenResult(
          forced == false && forceFirst,
        );

        injectToken(idToken.token!);
        final role = idToken.claims?["role"] ?? "";

        listen(DeliveryMan.fromUser(
          event,
          role == "deliver",
        ));
      }

      forced = true;
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

    // todo update only the information about the deliver man, so in security rules it become easy to check
    await firestore
        .collection('orders')
        .doc(order.id)
        .set(updatedOrder.toJson(), SetOptions(merge: true));

    await http.post(
      "order/delivery/start",
      data: jsonEncode(updatedOrder.toJson()),
    );
  }

  Future<Track> pushTrack(Track track) async {
    final response = await http.post(
      "order/delivery/track",
      data: jsonEncode(track.toJson()),
    );

    return Track.fromJson(response.data);
  }

  Future<void> finishTrack(Order order, LatLng deliverLocation) async {
    final deliveryManID = Server.auth.currentUser!.uid;
    final track = order.toTrack(deliveryManID, deliverLocation, true);

    await http.post(
      "order/delivery/finish",
      data: jsonEncode(track.toJson()),
    );
  }

  // todo rename it to something more meaningful
  Future<void> submitDelivery(
      String deliveryID, String phone, DeliverySubmit delivery) async {
    await Future.wait([
      firestore.collection('delivers').doc(deliveryID).set({
        ...delivery.toJson(),
        'active': false,
        'phone': phone,
      }),
      http.post("submitting/deliver"),
      auth.currentUser!.updateDisplayName(delivery.name),
      auth.currentUser!.updatePhotoURL(delivery.photo),
    ]);

    auth.currentUser!.reload();
  }

  Future<List<Order>> getDeliveredOrders(DateTime lastRead) async {
    final deliveryManID = Server.auth.currentUser!.uid;

    final query = await firestore
        .collection("orders")
        .where("deliveryManID", isEqualTo: deliveryManID)
        .where("lastUpdate", isGreaterThan: Timestamp.fromDate(lastRead))
        .get();

    final orders = query.docs
        .map((e) {
          final items = Utils.goodFirestoreJson(e.data());
          return Order.fromJson({...items, 'id': e.id});
        })
        .where((element) => element.isDelivered == true)
        .toList();

    return orders;
  }

// No configuration required - the plugin should work out of the box. It is however highly recommended to prepare for Android killing the application when low on memory. How to prepare for this is discussed in the Handling MainActivity destruction on Android section.
  Future<String?> pickImage(String fileName, String path) async {
    final ImagePicker picker = ImagePicker();
    // Pick an image.
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return null;
    final extention = image.path.split(".").last;
    // Capture a photo.

    Reference ref = storage.ref("$path/$fileName.$extention");
    // Start upload of putString
    await ref.putData(await image.readAsBytes());

    return await ref.getDownloadURL();
  }
}
