import 'package:firebase_auth/firebase_auth.dart';

class DeliveryMan {
  final String id;
  final String name;
  final String phone;
  final String photo;
  final bool isActive;

  DeliveryMan({
    required this.id,
    required this.name,
    required this.phone,
    required this.photo,
    required this.isActive,
  });

  static DeliveryMan fromUser(User user, bool isActive) {
    return DeliveryMan(
      id: user.uid,
      name: user.displayName ?? "Nabil",
      phone: user.phoneNumber ?? "+2136565652",
      photo: user.photoURL ?? "https://i.pravatar.cc/150?img=3",
      isActive: isActive,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'photo': photo,
    };
  }
}
