import 'package:deliver/models/order.dart';
import 'package:deliver/repository/direction.dart';

class DeliveryRequest {
  final Order order;
  final Direction toClient;
  final Direction toSeller;

  DeliveryRequest({
    required this.order,
    required this.toClient,
    required this.toSeller,
  });

  factory DeliveryRequest.fromJson(Map<String, dynamic> json) {
    return DeliveryRequest(
      order: Order.fromJson(json['order']),
      toClient: Direction.fromJson(json['toClient']),
      toSeller: Direction.fromJson(json['toSeller']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order': order.toJson(),
      'toClient': toClient.toJson(),
      'toSeller': toSeller.toJson(),
    };
  }
}
