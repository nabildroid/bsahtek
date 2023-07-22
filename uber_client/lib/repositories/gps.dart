import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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

  static Future<LatLng?> getLocation() async {
    final refusedToUseLocation =
        !await isPermitted() && !await requestPermission();

    if (refusedToUseLocation) {
      return null;
    } else {
      final coords = await getCurrentPosition();
      if (coords == null) return null;
      return LatLng(coords.dy, coords.dx);
    }
  }
}
