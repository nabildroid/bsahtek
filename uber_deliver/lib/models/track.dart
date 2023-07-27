import 'package:latlong2/latlong.dart';

class Track {
  final String orderID;
  final String id;
  final String clientID;
  final LatLng deliverLocation;
  final LatLng sellerLocation;
  final LatLng clientLocation;
  final bool toClient;
  final bool toSeller;
  final String deliveryManID;
  final String sellerID;

  Track({
    required this.orderID,
    required this.clientID,
    required this.toClient,
    required this.toSeller,
    required this.deliverLocation,
    required this.id,
    required this.sellerLocation,
    required this.deliveryManID,
    required this.sellerID,
    required this.clientLocation,
  });

  toJson() => {
        "orderID": orderID,
        "clientID": clientID,
        "clientLocation": {
          "latitude": clientLocation.latitude,
          "longitude": clientLocation.longitude,
        },
        if (toSeller) "toSeller": toSeller,
        "deliveryManID": deliveryManID,
        "sellerLocation": {
          "latitude": sellerLocation.latitude,
          "longitude": sellerLocation.longitude,
        },
        "sellerID": sellerID,
        "deliverLocation": {
          "latitude": deliverLocation.latitude,
          "longitude": deliverLocation.longitude,
        },
        "id": id,
      };

  factory Track.fromJson(Map<String, dynamic> json) {
    return Track(
      deliveryManID: json['deliveryManID'],
      sellerID: json['sellerID'],
      sellerLocation: LatLng(
        json['sellerLocation']['latitude'],
        json['sellerLocation']['longitude'],
      ),
      orderID: json['orderID'],
      clientID: json['clientID'],
      toClient: json['toClient'] ?? false,
      toSeller: json['toSeller'] ?? false,
      deliverLocation: LatLng(
        json['deliverLocation']['latitude'],
        json['deliverLocation']['longitude'],
      ),
      clientLocation: LatLng(
        json['clientLocation']['latitude'],
        json['clientLocation']['longitude'],
      ),
      id: json['id'],
    );
  }
}
