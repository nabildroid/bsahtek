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

  static DeliveryRequest? get runningRequest {
    final data = _instance.getString("deliveryRequest");
    if (data == null) return null;

    final info = jsonDecode(data);
    return DeliveryRequest.fromJson(info);
  }

  static set runningRequest(DeliveryRequest? request) {
    if (request != null) {
      _instance.setString("deliveryRequest", jsonEncode(request.toJson()));
    } else {
      _instance.remove("deliveryRequest");
    }
  }

  static DeliveryMan? get deliveryMan {
    final data = _instance.getString("deliveryMan");
    if (data == null) return null;

    final info = jsonDecode(data);
    return DeliveryMan(
      id: info['id'],
      name: info['name'],
      phone: info['phone'],
      photo: info['photo'],
      isActive: true,
    );
  }

  // setter for the deliverMan
  static set deliveryMan(DeliveryMan? deliveryMan) {
    if (deliveryMan != null) {
      _instance.setString(
        "deliveryMan",
        jsonEncode(deliveryMan.toJson()),
      );
    } else {
      _instance.remove("deliveryMan");
    }
  }

  static List<String> get attachedCells {
    return _instance.getStringList("cellAttachments") ?? [];
  }

  static set attachedCells(List<String> cells) {
    _instance.setStringList("cellAttachments", cells);
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
