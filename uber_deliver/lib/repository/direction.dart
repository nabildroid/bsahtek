import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_polyline_algorithm/google_polyline_algorithm.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as Http;

class Direction {
  final List<LatLng> points;
  final double distance;
  final Duration duration;

  Direction({
    required this.points,
    required this.distance,
    required this.duration,
  });

  static Direction fromJson(Map json) {
    return Direction(
      points: json["points"].map<LatLng>((e) => LatLng(e[0], e[1])).toList(),
      distance: json["distance"],
      duration: Duration(seconds: json["duration"]),
    );
  }

  Map toJson() {
    return {
      "points": points.map((e) => [e.latitude, e.longitude]).toList(),
      "distance": distance,
      "duration": duration.inSeconds,
    };
  }
}

abstract class DirectionRepository {
  static Future<Direction> direction(LatLng a, LatLng b) async {
    final uri = Uri.parse(
        "http://router.project-osrm.org/route/v1/driving/${a.longitude},${a.latitude};${b.longitude},${b.latitude}");

    final response = await Http.get(uri);

    final data = jsonDecode(response.body);

    final points =
        decodePolyline(data["routes"][0]["geometry"]) as List<List<num>>;

    return Direction(
      points:
          points.map((e) => LatLng(e[0].toDouble(), e[1].toDouble())).toList(),
      distance: data["routes"][0]["distance"] + 0.0,
      duration: Duration(seconds: data["routes"][0]["duration"].toInt()),
    );
  }

  static Future<String> getCityName(LatLng location) async {
    final response = await Http.get(
      Uri.parse(
          "https://nominatim.openstreetmap.org/reverse?format=json&lat=${location.latitude}&lon=${location.longitude}"),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final address = json["address"];
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

  static Offset roundToSquareCenter(double x, double y, int squareSpace) {
    const degreesPerKm = 1 / 111.32; // Approximate degrees per kilometer
    final squareSpaceDegrees = squareSpace * degreesPerKm;

    final roundedX = (x / squareSpaceDegrees).round() * squareSpaceDegrees;
    final roundedY = (y / squareSpaceDegrees).round() * squareSpaceDegrees;

    // Calculate center coordinates
    final centerX = roundedX + squareSpaceDegrees / 2;
    final centerY = roundedY + squareSpaceDegrees / 2;

    return Offset(
      (centerX * 1000).roundToDouble(),
      (centerY * 1000).roundToDouble(),
    );
  }
}
