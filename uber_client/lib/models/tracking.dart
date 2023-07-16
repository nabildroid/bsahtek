import 'package:google_maps_flutter/google_maps_flutter.dart';

class Tracking {
  final String id;
  final String orderID;
  final String clientId;

  final LatLng deliverLocation;
  final LatLng sellerLocation;
  final LatLng clientLocation;

  final DateTime createdAt;
  final DateTime updatedAt;

  final bool toClient;
  final bool toSeller;

  Tracking({
    required this.id,
    required this.clientId,
    required this.orderID,
    required this.toSeller,
    required this.toClient,
    required this.deliverLocation,
    required this.sellerLocation,
    required this.clientLocation,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Tracking.fromMap(Map<String, dynamic> map) {
    return Tracking(
      id: map['id'],
      clientId: map['clientID'],
      orderID: map['orderID'],
      deliverLocation: LatLng(map['deliverLocation']['latitude'],
          map['deliverLocation']['longitude']),
      sellerLocation: LatLng(map['sellerLocation']['latitude'],
          map['sellerLocation']['longitude']),
      clientLocation: LatLng(map['clientLocation']['latitude'],
          map['clientLocation']['longitude']),
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
      toClient: map['toClient'],
      toSeller: map['toSeller'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'clientId': clientId,
      'orderID': orderID,
      'deliverLocation': {
        'latitude': deliverLocation.latitude,
        'longitude': deliverLocation.longitude,
      },
      'sellerLocation': {
        'latitude': sellerLocation.latitude,
        'longitude': sellerLocation.longitude,
      },
      'clientLocation': {
        'latitude': clientLocation.latitude,
        'longitude': clientLocation.longitude,
      },
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'toClient': toClient,
      'toSeller': toSeller,
    };
  }
}
