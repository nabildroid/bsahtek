import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

// what hold of squares and what provide utils for dealing with them!

class MapSquare extends Equatable {
  final int latitude;
  final int longitude;
  final int zoomScale;
  final List<MapSquare> children = [];

  String get id => '$longitude,$latitude,$zoomScale';

  MapSquare({
    required this.latitude,
    required this.longitude,
    required this.zoomScale,
  });

  bool isInTheEdge(Offset pos) {
    return true;
  }

  factory MapSquare.fromOffset(Offset pos, int zoomScale) {
    final squareCenter = roundToSquareCenter(pos.dx, pos.dy, 30);
    final mainSquare = MapSquare(
      longitude: squareCenter.dx.round(),
      latitude: squareCenter.dy.round(),
      zoomScale: 30,
    );

    // todo  check if the pos is near by .3 the edge of the square, if so add the edge +2 as new child square
    return mainSquare;
  }

  Offset toOffset() {
    return centerSquareToPisition(longitude, latitude, zoomScale);
  }

  bool isWithin(LatLng pos) {
    final squareCenter = roundToSquareCenter(pos.longitude, pos.latitude, 30);
    final mainSquare = MapSquare(
      longitude: squareCenter.dx.round(),
      latitude: squareCenter.dy.round(),
      zoomScale: 30,
    );

    return mainSquare.id == id;
  }

  List<LatLng> toPoints() {
    final List<LatLng> points = [
      LatLng(
        addKlmToLongitude(toOffset().dy, -zoomScale ~/ 2),
        addKlmToLongitude(toOffset().dx, -zoomScale ~/ 2),
      ),
      LatLng(
        addKlmToLongitude(toOffset().dy, -zoomScale ~/ 2),
        addKlmToLongitude(toOffset().dx, zoomScale ~/ 2),
      ),
      LatLng(
        addKlmToLongitude(toOffset().dy, zoomScale ~/ 2),
        addKlmToLongitude(toOffset().dx, zoomScale ~/ 2),
      ),
      LatLng(
        addKlmToLongitude(toOffset().dy, zoomScale ~/ 2),
        addKlmToLongitude(toOffset().dx, -zoomScale ~/ 2),
      ),
    ];

    return points;
  }

  static LatLng getCenter(List<LatLng> points) {
    double x = 0;
    double y = 0;
    double z = 0;

    for (LatLng point in points) {
      double latitude = point.latitude * pi / 180;
      double longitude = point.longitude * pi / 180;

      x += cos(latitude) * cos(longitude);
      y += cos(latitude) * sin(longitude);
      z += sin(latitude);
    }

    int total = points.length;

    x = x / total;
    y = y / total;
    z = z / total;

    double centralLongitude = atan2(y, x);
    double centralSquareRoot = sqrt(x * x + y * y);
    double centralLatitude = atan2(z, centralSquareRoot);

    return LatLng(centralLatitude * 180 / pi, centralLongitude * 180 / pi);
  }

  static double addKlmToLongitude(double longitude, int kilometers) {
    const degreesPerKm = 1 / 111.32; // Approximate degrees per kilometer
    final distanceInDegrees = kilometers * degreesPerKm;
    final newLongitude = longitude + distanceInDegrees;
    return newLongitude;
  }

  static double calculateDifferenceInKm(double value1, double value2) {
    const double degreesPerKm = 1 / 111.32; // Approximate degrees per kilometer
    double differenceInDegrees = value1 - value2;
    double differenceInKm = differenceInDegrees / degreesPerKm;
    return differenceInKm;
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

  static Offset centerSquareToPisition(int x, int y, int squareSpace) {
    const degreesPerKm = 1 / 111.32; // Approximate degrees per kilometer
    final squareSpaceDegrees = squareSpace * degreesPerKm;

    // Convert input x and y back to the original scale
    final centerX = x / 1000;
    final centerY = y / 1000;

    // Calculate the rounded x and y coordinates
    final roundedX = centerX - squareSpaceDegrees / 2;
    final roundedY = centerY - squareSpaceDegrees / 2;

    return Offset(roundedX, roundedY);
    // todo this function does not work properly!!
  }

  static LatLngBounds createBounds(LatLng centre, int klmRaduis) {
    // raduis is in in km
    final double latRadian = centre.latitude * pi / 180;
    const double degLatKlm = 1 / 111.32; // Approximate degrees per kilometer
    final double degLonKlm = 1 / (111.32 * cos(latRadian));

    final double latKlm = klmRaduis * degLatKlm;
    final double lonKlm = klmRaduis * degLonKlm;

    final LatLng southWest =
        LatLng(centre.latitude - latKlm, centre.longitude - lonKlm);
    final LatLng northEast =
        LatLng(centre.latitude + latKlm, centre.longitude + lonKlm);

    return LatLngBounds(southwest: southWest, northeast: northEast);
  }

  static double calculateZoomLevel(double radius, double screenWidth) {
    double equatorLength = 40030000; // in meters, a more accurate average

    double desiredWidthKm = radius * 2; // Convert radius to diameter
    double desiredWidthMeters = desiredWidthKm * 1000; // Convert km to m
    double metersPerPixel = equatorLength /
        256; // At zoom level 1, the earth's equator is 256 pixels long
    double zoomLevel = 1.0;
    while ((metersPerPixel * screenWidth) > desiredWidthMeters) {
      metersPerPixel /= 2;
      zoomLevel += 1.0;
    }
    return zoomLevel;
  }

  @override
  List<Object?> get props => [id, ...children.map((e) => e.id).toList()];
}
