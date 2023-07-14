import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import "package:http/http.dart" as Http;
import 'package:latlong2/latlong.dart';
import 'package:uber_deliver/models/delivery_man.dart';

import '../models/track.dart';

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
    return firestore.collection('delivertMan').doc(deliveryManID).set({
      'notiID': notiID,
    }, SetOptions(merge: true));
  }

  Future<void> updateAvailability(String userID) async {}

  Future<void> track(Track track) async {}
}
