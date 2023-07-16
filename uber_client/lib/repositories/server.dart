import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import "package:http/http.dart" as Http;

import '../models/bag.dart';
import '../models/client.dart';
import '../models/order.dart';
import '../models/tracking.dart';
import '../utils/firebase.dart';

final endpoint =
    (String path) => Uri.parse("http://192.168.0.105:3000/api/$path");

class Server {
  static late FirebaseFirestore firestore;
  static late FirebaseAuth auth;

  static Future<void> init() async {
    await Firebase.initializeApp();
    firestore = FirebaseFirestore.instance;
    auth = FirebaseAuth.instance;
  }

  Server();

  Future<Client?> getCurrentClient() async {
    final Completer<Client?> completer = Completer();
    final stream = auth.authStateChanges().listen((User? user) {
      if (user == null) {
        completer.complete(null);
      } else {
        completer.complete(Client(
          id: user.uid,
          name: user.displayName ?? "",
          phone: user.phoneNumber ?? "",
        ));
      }
    });

    final data = await completer.future;
    await stream.cancel();

    return data;
  }

  Future<Future<Client> Function(String)> loginByPhone(String phone) async {
    final OTPcompleter = Completer<Future<Client> Function(String otp)>();

    await auth.verifyPhoneNumber(
      phoneNumber: phone,
      verificationCompleted: (PhoneAuthCredential credential) async {
        final user = await auth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        print(e.message);
      },
      codeSent: (String verificationId, int? resendToken) {
        OTPcompleter.complete((String otp) async {
          final credential = PhoneAuthProvider.credential(
            verificationId: verificationId,
            smsCode: otp,
          );
          final user = await auth.signInWithCredential(credential);
          return Client(
            id: user.user!.uid,
            name: user.user!.displayName ?? "User",
            phone: user.user!.phoneNumber ?? "",
          );
        });
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );

    return OTPcompleter.future;
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

    final response = await Http.post(
      endpoint("order"),
      body: jsonEncode(data),
      headers: {
        "Content-Type": "application/json",
      },
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
}
