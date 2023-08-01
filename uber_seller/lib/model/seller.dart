import 'package:firebase_auth/firebase_auth.dart';
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
  final bool isActive;

  Seller({
    required this.id,
    required this.name,
    required this.photo,
    required this.phone,
    this.isActive = false,
  });

  factory Seller.fromJson(Map<String, dynamic> json) {
    return Seller(
      id: json['id'],
      name: json['name'],
      photo: json['photo'],
      phone: json['phone'],
      isActive: json['isActive'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'photo': photo,
      'phone': phone,
      'isActive': isActive,
    };
  }

  static Seller fromUser(User user, bool isActive) {
    return Seller(
      id: user.uid,
      name: user.displayName ?? "Seller",
      photo: user.photoURL ?? "",
      phone: user.phoneNumber ?? "",
      isActive: isActive,
    );
  }

  Seller copyWith({
    String? name,
    String? photo,
  }) {
    return Seller(
      name: name ?? this.name,
      photo: photo ?? this.photo,
      id: id,
      phone: phone,
      isActive: isActive,
    );
  }
}
