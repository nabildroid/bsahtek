import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class GpsRepository {
  static Future<Offset?> getCurrentPosition() async {
    try {
      return await Geolocator.getCurrentPosition().then((value) {
        return Offset(value.longitude, value.latitude);
      });
    } catch (e) {
      return await Geolocator.getLastKnownPosition().then((value) {
        if (value != null) return Offset(value.longitude, value.latitude);
      });
    }
  }

  void subscibeToPositionChanges(Function(Offset) callback) {}

  static Future<bool> isPermitted() async {
    final permssion = await Geolocator.checkPermission();
    return permssion == LocationPermission.always ||
        permssion == LocationPermission.whileInUse;
  }

  static Future<bool> requestPermission() async {
    final permssion = await Geolocator.requestPermission();
    return permssion == LocationPermission.always ||
        permssion == LocationPermission.whileInUse;
  }
}
