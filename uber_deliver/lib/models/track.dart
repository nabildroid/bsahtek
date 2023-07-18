import 'package:latlong2/latlong.dart';

class Track {
  final String orderID;
  final String id;
  final String clientID;
  final LatLng delivertLocation;
  final bool toClient;
  final bool toSeller;

  Track({
    required this.orderID,
    required this.clientID,
    required this.toClient,
    required this.toSeller,
    required this.delivertLocation,
    required this.id,
  });

  toJson() => {
        "orderID": orderID,
        "clientID": clientID,
        "toClient": toClient,
        "toSeller": toSeller,
        "delivertLocation": {
          "latitude": delivertLocation.latitude,
          "longitude": delivertLocation.longitude,
        },
        "id": id,
      };

  factory Track.fromJson(Map<String, dynamic> json) {
    return Track(
      orderID: json['orderID'],
      clientID: json['clientID'],
      toClient: json['toClient'],
      toSeller: json['toSeller'],
      delivertLocation: LatLng(
        json['delivertLocation']['latitude'],
        json['delivertLocation']['longitude'],
      ),
      id: json['id'],
    );
  }
}