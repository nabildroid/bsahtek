import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import "package:http/http.dart" as Http;
import 'package:uber_seller/model/bag.dart';

import '../model/seller.dart';
import '../model/order.dart' as Model;
import '../utils/firestore.dart';

final endpoint =
    (String path) => Uri.parse("http://192.168.0.105:3000/api/$path");

class Server {
  static late FirebaseFirestore firestore;

  static Future<void> init() async {
    final firebase = await Firebase.initializeApp();
    firestore = FirebaseFirestore.instance;
  }

  Server();

  Future<List<Bag>> _getBags(String sellerID) async {
    final response = await Http.get(endpoint("seller/$sellerID/bags"));
    final json = jsonDecode(response.body)["bags"];

    return json.map<Bag>((e) => Bag.fromJson(e)).toList();
  }

  Future<Seller> getSeller(String sellerID) async {
    final bags = await _getBags(sellerID);

    return Seller.fromBags(bags);
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
    String? sellerID,
    String? notiID,
  }) {
    return firestore.collection('sellers').doc(sellerID).update({
      'notiID': notiID,
    });
  }

  Future<void> acceptOrder(Model.Order order) async {
    await Http.post(
      endpoint("order/accept"),
      body: jsonEncode(order.toJson()),
      headers: {
        "Content-Type": "application/json",
      },
    );
  }

  Future<VoidCallback> listenToOrders({
    required String sellerID,
    required DateTime lastUpdated,
    required void Function(List<Model.Order>) onChange,
  }) async {
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
}
