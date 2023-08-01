import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uber_client/utils/constants.dart';

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
  final bool isPickup;

  final String sellerID;
  final LatLng? sellerAddress;
  final String? sellerPhone;
  final String? sellerName;
  final DateTime? acceptedAt;

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
    this.deliveryPath,
    this.sellerAddress,
    this.deliveryManID,
    this.deliveryPhone,
    this.deliveryName,
    this.acceptedAt,
    required this.isPickup,
    this.sellerPhone,
    this.sellerName,
  });

  // todo you can add multiple factories to model multiple states of this order

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
      'sellerPhone': sellerPhone,
      'sellerName': sellerName,
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
        json['clientAddress']['latitude'],
        json['clientAddress']['longitude'],
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
            value['latitude'],
            value['longitude'],
          ),
        ),
      ),
      sellerAddress: json['sellerAddress'] != null
          ? LatLng(
              json['sellerAddress']['latitude'],
              json['sellerAddress']['longitude'],
            )
          : null,
      sellerPhone: json['sellerPhone'],
      sellerName: json['sellerName'],
      deliveryManID: json['deliveryManID'],
      deliveryPhone: json['deliveryPhone'],
      deliveryName: json['deliveryName'],
      acceptedAt: json['acceptedAt'] != null
          ? DateTime.parse(json['acceptedAt'])
          : null,
      isPickup: json['isPickup'] ?? false,
    );
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

  bool get isItRunning {
    return isDelivered != true && expired == false && deliveryManID != null;
  }
}
