import 'dart:convert';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as Http;

abstract class Geocoding {
  static Future<String> getCityName(LatLng location) async {
    final response = await Http.get(
      Uri.parse(
          "https://nominatim.openstreetmap.org/reverse?format=json&lat=${location.latitude}&lon=${location.longitude}"),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return json["address"]["town"] as String;
    } else {
      return "";
    }
  }

  static Future<Map<String, LatLng>> searchAddress(String address) async {
    final response = await Http.get(
      Uri.parse("https://nominatim.openstreetmap.org/search?format=json&q=" +
          address),
    );

    if (response.statusCode == 200) {
      final List<dynamic> json = jsonDecode(response.body) as List<dynamic>;
      final Map<String, LatLng> suggestions = {};
      for (final item in json) {
        suggestions[item["display_name"]] =
            LatLng(double.parse(item["lat"]), double.parse(item["lon"]));
      }
      return suggestions;
    } else
      return {};
  }
}
