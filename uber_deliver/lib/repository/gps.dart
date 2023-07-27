import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class GpsRepository {
  static Future<Offset?> getCurrentPosition() async {
    try {
      var pos = await Future.any([
        Future.delayed(Duration(seconds: 1)),
        Geolocator.getCurrentPosition().then((value) {
          return Offset(value.longitude, value.latitude);
        })
      ] as Iterable<Future>);

      pos ??= await Future.any([
        Future.delayed(Duration(seconds: 1)),
        Geolocator.getCurrentPosition().then((value) {
          return Offset(value.longitude, value.latitude);
        })
      ]);

      if (pos == null) throw Exception("Couldn't get the frech location");
      return pos;
    } catch (e) {
      return await Geolocator.getLastKnownPosition().then((value) {
        if (value != null) return Offset(value.longitude, value.latitude);
        return null;
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

  static Future<LatLng?> getLocation({bool goThrough = false}) async {
    return LatLng(36.2233081, 4.5161926);
    if (goThrough == false) {
      final refusedToUseLocation = !await GpsRepository.isPermitted() &&
          !await GpsRepository.requestPermission();
      if (refusedToUseLocation) {
        return null;
      }
    }

    final coords = await GpsRepository.getCurrentPosition();
    if (coords == null) return null;
    return LatLng(coords.dy, coords.dx);
  }
}
