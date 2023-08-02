import 'package:store/model/bag.dart';
import 'package:store/model/seller.dart';

import '../utils/constants.dart';

class Order {
  final String id;
  final int quantity;

  final DateTime lastUpdate;
  final DateTime createdAt;

  final String clientID;
  final String clientName;
  final String clientPhone;
  final LatLng clientAddress;
  final String clientTown;

  final String sellerID;
  final LatLng? sellerAddress;
  final String? sellerName;
  final String? sellerPhone;

  final String bagID;
  final String bagName;
  final String bagImage;
  final String bagPrice;
  final String bagDescription;

  final String? reportId;

  final bool? isDelivered;
  final Map<String, LatLng>? deliveryPath;
  final String? deliveryManID;
  final String? deliveryPhone;
  final String? deliveryName;
  final DateTime? acceptedAt;
  final bool isPickup;

  const Order({
    required this.id,
    required this.sellerID,
    required this.clientID,
    required this.clientName,
    required this.clientPhone,
    required this.clientAddress,
    required this.bagID,
    required this.bagName,
    required this.bagImage,
    required this.bagPrice,
    required this.bagDescription,
    required this.createdAt,
    required this.quantity,
    required this.lastUpdate,
    this.reportId,
    required this.clientTown,
    this.isDelivered,
    required this.deliveryPath,
    this.sellerAddress,
    this.sellerName,
    this.sellerPhone,
    this.deliveryManID,
    this.deliveryPhone,
    this.deliveryName,
    this.acceptedAt,
    required this.isPickup,
  });

  toJson() {
    return {
      'id': id,
      'sellerID': sellerID,
      'clientID': clientID,
      'clientName': clientName,
      'clientPhone': clientPhone,
      'clientAddress': {
        'latitude': clientAddress.latitude,
        'longitude': clientAddress.longitude,
      },
      'bagID': bagID,
      'bagName': bagName,
      'bagImage': bagImage,
      'bagPrice': bagPrice,
      'bagDescription': bagDescription,
      'createdAt': createdAt.toUtc().toIso8601String(),
      'quantity': quantity,
      'lastUpdate': lastUpdate.toUtc().toIso8601String(),
      'reportId': reportId,
      'clientTown': clientTown,
      'isDelivered': isDelivered,
      'deliveryPath': deliveryPath?.map((key, value) => MapEntry(key, {
            'latitude': value.latitude,
            'longitude': value.longitude,
          })),
      'sellerAddress': sellerAddress != null
          ? {
              'latitude': sellerAddress!.latitude,
              'longitude': sellerAddress!.longitude,
            }
          : null,
      'sellerName': sellerName,
      'sellerPhone': sellerPhone,
      'deliveryManID': deliveryManID,
      'deliveryPhone': deliveryPhone,
      'deliveryName': deliveryName,
      'acceptedAt': acceptedAt?.toUtc().toIso8601String(),
      'isPickup': isPickup,
    };
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      sellerID: json['sellerID'],
      clientID: json['clientID'],
      clientName: json['clientName'],
      clientPhone: json['clientPhone'],
      clientAddress: LatLng(
        latitude: json['clientAddress']['latitude'],
        longitude: json['clientAddress']['longitude'],
      ),
      bagID: json['bagID'],
      bagName: json['bagName'],
      bagImage: json['bagImage'],
      bagPrice: json['bagPrice'],
      bagDescription: json['bagDescription'],
      createdAt: DateTime.parse(json['createdAt']),
      quantity: json['quantity'],
      lastUpdate: DateTime.parse(json['lastUpdate']),
      reportId: json['reportId'],
      clientTown: json['clientTown'],
      isDelivered: json['isDelivered'],
      deliveryPath: json['deliveryPath']?.map<String, LatLng>(
        (key, value) => MapEntry(
          key,
          LatLng(
            latitude: value['latitude'],
            longitude: value['longitude'],
          ),
        ),
      ),
      sellerAddress: json['sellerAddress'] != null
          ? LatLng(
              latitude: json['sellerAddress']['latitude'] + .0,
              longitude: json['sellerAddress']['longitude'] + .0,
            )
          : null,
      sellerName: json['sellerName'],
      sellerPhone: json['sellerPhone'],
      deliveryManID: json['deliveryManID'],
      deliveryPhone: json['deliveryPhone'],
      deliveryName: json['deliveryName'],
      acceptedAt: json['acceptedAt'] != null
          ? DateTime.parse(json['acceptedAt'])
          : null,
      isPickup: json['isPickup'] ?? false,
    );
  }

  Order accept(Seller seller, Bag bag) {
    if (bag.id.toString() != bagID) {
      throw Exception("Bag id is not the same");
    }

    if (seller.id != sellerID) {
      throw Exception("Seller id is not the same");
    }

    final data = toJson();
    data["acceptedAt"] = DateTime.now().toUtc().toIso8601String();
    data["sellerAddress"] = {
      "latitude": bag.latitude,
      "longitude": bag.longitude,
    };
    data["sellerName"] = seller.name;
    data["sellerPhone"] = seller.phone;

    return Order.fromJson(data);
  }

// todo later move this logic to the server
  bool get expired {
    // todo you can throw an error with explanation if this order is expired, instead of returning true
    if (isDelivered == true) {
      return false;
    }

    // todo need revalidate this logic
    final now = DateTime.now();
    if (now.difference(lastUpdate) > Constants.lastUpdateBeforeExpired) {
      // fall over to not let any edge case pass, including deliver take too long
      return true;
    }

    if (acceptedAt == null &&
        now.difference(lastUpdate) > Constants.needAcceptanceBeforeExpired) {
      print("Order#$id expired: needAcceptanceBeforeExpired");
      return true;
    }

    if (isPickup &&
        acceptedAt != null &&
        now.difference(acceptedAt!) > Constants.needSelfPickupBeforeExpired) {
      print("Order#$id expired: needSelfPickupBeforeExpired");
      return true;
    }

    if (isPickup == false &&
        deliveryManID == null &&
        acceptedAt != null &&
        now.difference(acceptedAt!) > Constants.needDeliverBeforeExpired) {
      print("Order#$id expired: needDeliverBeforeExpired");
      return true;
    }

    return false;
  }

  bool get inProgress {
    return isDelivered != true && expired == false;
  }
}
