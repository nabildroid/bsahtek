import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:store/model/bag.dart';

import '../model/seller.dart';
import '../model/order.dart' as Model;
import '../model/sellerSubmit.dart';
import '../model/zone.dart';
import '../utils/firestore.dart';

class Server {
  static late FirebaseFirestore firestore;
  static late FirebaseStorage storage;

  static late FirebaseAuth auth;
  static Dio http = Dio(BaseOptions(
    baseUrl: "https://wastnothin.vercel.app/api/",
  ));

  static Future<void> init() async {
    await Firebase.initializeApp();
    firestore = FirebaseFirestore.instance;
    auth = FirebaseAuth.instance;
    storage = FirebaseStorage.instance;
    // await auth.signOut();
  }

  Server();

  Future<List<Bag>> getBags() async {
    final sellerID = auth.currentUser!.uid;
    final response = await http.get("seller/$sellerID/bags");
    final json = response.data["bags"];

    return json.map<Bag>((e) => Bag.fromJson(e)).toList();
  }

  Future<List<Zone>> getZones(List<String> bagsIds) async {
    final ref = firestore.collection("zones");

    //  todo add also the last updated to prevent refetching the same data

    final id = "quantities.${bagsIds[0]}";
    // todo to ensure security make it like "qunanities.sellerID.bagID" and enforce it through security rules
    final queries = await Future.wait(bagsIds.map(
      (bagdId) => ref.where(id, isNull: false).get(),
    ));

    final docs = queries.map((e) => e.docs).expand((e) => e).toList();

    return docs.map((e) {
      final data = e.data();
      return Zone(
        id: e.id,
        quantities: Map<String, int>.from(data["quantities"]),
      );
    }).toList();
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
    // sometime it's called mutliple times (7times!), so we need to force it to be called once
    bool isGood = false;
    final sub = auth.authStateChanges().listen((event) async {
      if (event == null) {
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
    final query = firestore
        .collection("orders")
        .where("sellerID", isEqualTo: sellerID)
        .where("lastUpdate", isGreaterThan: Timestamp.fromDate(lastUpdated));
    // todo add condition to prevent push Noti to interfer with this!

    final stream = query.snapshots().listen((event) {
      final List<Model.Order> changes = [];

      event.docChanges.forEach((change) {
        if (change.type == DocumentChangeType.removed) return;

        final doc = change.doc.data();

        changes.add(Model.Order.fromJson(
          FirestoreUtils.goodJson(
            {...doc!, "id": change.doc.id},
          ),
        ));
      });

      onChange(changes);
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
      http.post("submitting/seller"),
      auth.currentUser!.updateDisplayName(seller.name),
      auth.currentUser!.updatePhotoURL(seller.photo),
    ]);

    auth.currentUser!.reload();
    // update the user account!
  }

  Timer? debounce1;

  Future<void> addQuantity(List<Zone> zones, String bagID, int quantity) async {
    if (debounce1 != null && debounce1!.isActive) debounce1!.cancel();
    debounce1 = Timer(const Duration(seconds: 1), () async {
      for (var zone in zones) {
        if (zone.quantities.containsKey(bagID)) {
          final ref = firestore.collection("zones").doc(zone.id);
          await ref.set({
            "quantities": {
              bagID: quantity == 0
                  ? 0
                  : quantity.abs() == 1
                      ? FieldValue.increment(quantity)
                      : quantity,
            }
          }, SetOptions(merge: true));
        }
      }
    });
  }

  Future<String> getCityName(LatLng location) async {
    final response = await Dio().get(
      "https://nominatim.openstreetmap.org/reverse?format=json&lat=${location.latitude}&lon=${location.longitude}",
    );

    if (response.statusCode == 200) {
      final json = response.data;
      final address = json["address"];
      if (address == null) return "";
      String city;
      if (address.containsKey("town")) {
        city = address["town"];
      } else if (address.containsKey("county")) {
        city = address["county"];
      } else if (address.containsKey("village")) {
        city = address["village"];
      } else {
        city = "";
      }
      return city;
    } else {
      return "";
    }
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
