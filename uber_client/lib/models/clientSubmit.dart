import 'package:bsahtak/models/order.dart';

class ClientSubmit {
  final String name;
  final String address;
  final String phone;
  final String photo;
  final String? email;
  final bool active;
  final Order requestedOrder;

  ClientSubmit({
    required this.name,
    required this.address,
    required this.phone,
    required this.requestedOrder,
    this.email,
    this.active = false,
  }) : photo = "https://api.dicebear.com/6.x/identicon/png?seed=+213" + phone;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'phone': phone,
      'email': email,
      'active': active,
      'photo': photo,
      'requestedOrder': requestedOrder.toJson(),
    };
  }
}
