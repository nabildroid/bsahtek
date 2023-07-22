import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:uber_seller/model/bag.dart';

import '../model/seller.dart';
import '../model/order.dart' as Model;
import '../model/sellerSubmit.dart';
import '../utils/firestore.dart';

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
    // auth.signOut();
  }

  Server();

  Future<List<Bag>> getBags() async {
    final sellerID = auth.currentUser!.uid;
    final response = await http.get("seller/$sellerID/bags");
    final json = response.data["bags"];

    return json.map<Bag>((e) => Bag.fromJson(e)).toList();
  }

  Future<Map<String, int>> getQuantities(List<String> bagsIds) async {
    final ref = firestore.collection("zones");

    // todo to ensure security make it like "qunanities.sellerID.bagID" and enforce it through security rules
    final queries = await Future.wait(bagsIds.map(
      (bagdId) => ref.where("quantities.$bagsIds[0]", isNotEqualTo: null).get(),
    ));

    final docs = queries.map((e) => e.docs).expand((e) => e).toList();

    final quantities = <String, int>{};

    for (var doc in docs) {
      for (var bagId in bagsIds) {
        final quantity = doc.data()["quantities"][bagId];
        if (quantity != null) {
          quantities[bagId] = quantity;
        }
      }
    }

    return quantities;
  }

  Future<void> assignNotiIDtoSeller({
    required String sellerID,
    required String notiID,
  }) {
    return firestore.collection('sellers').doc(sellerID).update({
      'notiID': notiID,
    });
  }

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

  VoidCallback onUserChange(Function(Seller?) listen,
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

        listen(Seller.fromUser(
          event,
          role == "seller",
        ));
      }
    });

    return sub.cancel;
  }

  Future<void> acceptOrder(Model.Order order) async {
    await http.post("order/accept", data: jsonEncode(order.toJson()));
  }

  Future<void> handOver(Model.Order order) async {
    await http.post("order/handover", data: jsonEncode(order.toJson()));
  }

  Future<VoidCallback> listenToOrders({
    required DateTime lastUpdated,
    required void Function(List<Model.Order>) onChange,
  }) async {
    final sellerID = auth.currentUser!.uid;
    final query = firestore.collection("orders");
    // .where("sellerID", isEqualTo: sellerID)
    // .where("updatedAt", isGreaterThan: lastUpdated);
    // todo add condition to prevent push Noti to interfer with this!

    final stream = query.snapshots().listen((event) {
      // todo handle date time
      final orders = event.docs
          .map((e) => Model.Order.fromJson(
                FirestoreUtils.goodJson(
                  {...e.data(), "id": e.id},
                ),
              ))
          .toList();
      onChange.call(orders);
    });

    return stream.cancel;
  }

  Future<void> submitSeller(
      String sellerID, String phone, SellerSubmit seller) async {
    await Future.wait([
      firestore.collection('sellers').doc(sellerID).set({
        ...seller.toJson(),
        'active': false,
        'phone': phone,
      }),
      auth.currentUser!.updateDisplayName(seller.name),
      auth.currentUser!.updatePhotoURL(seller.photo),
    ]);

    auth.currentUser!.reload();
    // update the user account!
  }
}
