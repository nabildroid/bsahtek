import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

final Http = Dio();

abstract class Geocoding {
  static final http = Http
    ..interceptors.add(RetryInterceptor(
      dio: Http,
      logPrint: print, // specify log function (optional)
      retries: 3, // retry count (optional)
      retryDelays: const [
        // set delays between retries (optional)
        Duration(seconds: 1), // wait 1 sec before first retry
        Duration(seconds: 5), // wait 2 sec before second retry
        Duration(seconds: 30), // wait 3 sec before third retry
      ],
    ));

  static Future<String> getCityName(LatLng location) async {
    try {
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
    } catch (e) {
      return "";
    }
  }

  static Future<Map<String, LatLng>> searchAddress(String address) async {
    try {
      final response = await http.get(
        "https://nominatim.openstreetmap.org/search?format=json&q=" + address,
      );

      if (response.statusCode == 200) {
        final List<dynamic> json = response.data as List<dynamic>;
        final Map<String, LatLng> suggestions = {};
        for (final item in json) {
          suggestions[item["display_name"]] =
              LatLng(double.parse(item["lat"]), double.parse(item["lon"]));
        }
        return suggestions;
      } else
        return {};
    } catch (e) {
      return {};
    }
  }
}
