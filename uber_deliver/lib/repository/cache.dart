import 'dart:convert';

import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uber_deliver/models/delivery_man.dart';
import 'package:uber_deliver/repository/direction.dart';

import '../models/delivery_request.dart';
import '../models/order.dart';
import '../models/track.dart';

abstract class Cache {
  static late SharedPreferences _instance;
  static Future<void> init() async {
    _instance = await SharedPreferences.getInstance();
  }

  static bool get isFirstRun {
    final isIt = _instance.getBool("isFirstRun") ?? true;
    _instance.setBool("isFirstRun", false);

    return isIt;
  }

  static DeliveryMan? get getDeliveryMan {
    final data = _instance.getString("deliveryManID");
    if (data == null) return null;

    final info = jsonDecode(data);
    return DeliveryMan(
      id: info['id'],
      name: info['name'],
      phone: info['phone'],
      photo: info['photo'],
    );
  }

  static List<String> get attachedCells {
    return _instance.getStringList("cellAttachments") ?? [];
  }

  static set attachedCells(List<String> cells) {
    _instance.setStringList("cellAttachments", cells);
  }

  static Track? get lastTrack {
    final data = _instance.getString("lastTrack");
    if (data == null) return null;

    final info = jsonDecode(data);
    return Track.fromJson(info);
  }

  static set lastTrack(Track? track) {
    if (track != null) {
      _instance.setString("lastTrack", jsonEncode(track.toJson()));
    } else {
      _instance.remove("lastTrack");
    }
  }

  static LatLng? get availabilityLocation {
    final data = _instance.getString("availabilityLocation");
    if (data == null) return null;

    final info = jsonDecode(data);
    return LatLng(info[0], info[1]);
  }

  static Future<void> setAvailabilityLocation(LatLng? location) async {
    if (location != null) {
      await _instance.setString("availabilityLocation",
          jsonEncode([location.latitude, location.longitude]));
    } else {
      _instance.remove("availabilityLocation");
    }
  }

  // get delivery request data by orderID
  static DeliveryRequest? getDeliveryRequestData(
    String orderID,
  ) {
    final data = _instance.getString("deliveryRequestData");
    if (data == null) return null;

    final info = jsonDecode(data);
    if (info[orderID] == null) return null;

    return DeliveryRequest.fromJson(info[orderID]);
  }

  static List<DeliveryRequest> get deliveryRequests {
    final data = _instance.getString("deliveryRequestData");
    if (data == null) return [];

    final info = jsonDecode(data);
    return info.values
        .map<DeliveryRequest>((e) => DeliveryRequest.fromJson(e))
        .toList();
  }

  static Future<void> saveDeliveryRequestData(DeliveryRequest request) async {
    final data = _instance.getString("deliveryRequestData");
    if (data == null) {
      await _instance.setString(
        "deliveryRequestData",
        jsonEncode({request.order.id: request.toJson()}),
      );
    } else {
      final info = jsonDecode(data);
      info[request.order.id] = request.toJson();
      await _instance.setString("deliveryRequestData", jsonEncode(info));
    }
  }
}
