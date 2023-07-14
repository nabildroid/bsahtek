import 'package:latlong2/latlong.dart';

class Track {
  final String orderID;
  final String clientID;
  final LatLng currentLocation;
  final LatLng startLocation;
  final LatLng clientLocation;
  final LatLng sellerLocation;
  final bool toClient;

  Track({
    required this.orderID,
    required this.clientID,
    required this.currentLocation,
    required this.startLocation,
    required this.clientLocation,
    required this.sellerLocation,
    required this.toClient,
  });

  toJson() => {
        "orderID": orderID,
        "clientID": clientID,
        "currentLocation": {
          "latitude": currentLocation.latitude,
          "longitude": currentLocation.longitude,
        },
        "startLocation": {
          "latitude": startLocation.latitude,
          "longitude": startLocation.longitude,
        },
        "clientLocation": {
          "latitude": clientLocation.latitude,
          "longitude": clientLocation.longitude,
        },
        "sellerLocation": {
          "latitude": sellerLocation.latitude,
          "longitude": sellerLocation.longitude,
        },
        "toClient": toClient,
      };

  factory Track.fromJson(Map<String, dynamic> json) {
    return Track(
      orderID: json['orderID'],
      clientID: json['clientID'],
      currentLocation: LatLng(
        json['currentLocation']['latitude'],
        json['currentLocation']['longitude'],
      ),
      startLocation: LatLng(
        json['startLocation']['latitude'],
        json['startLocation']['longitude'],
      ),
      clientLocation: LatLng(
        json['clientLocation']['latitude'],
        json['clientLocation']['longitude'],
      ),
      sellerLocation: LatLng(
        json['sellerLocation']['latitude'],
        json['sellerLocation']['longitude'],
      ),
      toClient: json['toClient'],
    );
  }
}
