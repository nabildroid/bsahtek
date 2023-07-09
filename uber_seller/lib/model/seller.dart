import 'package:uber_seller/model/bag.dart';

class LatLng {
  final double latitude;
  final double longitude;

  LatLng({
    required this.latitude,
    required this.longitude,
  });
}

class Seller {
  final String id;
  final String name;
  final String photo;
  final String phone;
  final LatLng location;
  final List<Bag> bags;

  Seller({
    required this.id,
    required this.name,
    required this.photo,
    required this.phone,
    required this.location,
    required this.bags,
  });

  factory Seller.fromJson(Map<String, dynamic> json) {
    return Seller(
      id: json['id'],
      name: json['name'],
      photo: json['photo'],
      phone: json['phone'],
      location: LatLng(
        latitude: json['location']['latitude'],
        longitude: json['location']['longitude'],
      ),
      bags: json['bags'].map<Bag>((e) => Bag.fromJson(e)).toList(),
    );
  }

  factory Seller.fromBags(List<Bag> bags) {
    return Seller(
      id: bags.first.id.toString(),
      name: bags.first.sellerName,
      photo: bags.first.sellerPhoto,
      location: LatLng(
        latitude: bags.first.latitude,
        longitude: bags.first.longitude,
      ),
      phone: '+2133333333',
      bags: bags,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'photo': photo,
      'phone': phone,
      'location': {
        'latitude': location.latitude,
        'longitude': location.longitude,
      },
      'bags': bags.map((e) => e.toJson()).toList(),
    };
  }
}
