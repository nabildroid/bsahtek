import 'dart:convert';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:uber_deliver/repository/background.dart';
import 'package:uber_deliver/repository/gps.dart';
import 'package:uber_deliver/repository/messages_remote.dart';
import 'package:uber_deliver/repository/notifications.dart';
import 'package:uber_deliver/screens/running.dart';

import '../models/delivery_request.dart';
import '../models/order.dart';
import '../repository/cache.dart';
import '../repository/direction.dart';
import '../utils/utils.dart';

class ServiceState extends Equatable {
  final bool isAvailable;
  final bool isDelivering;

  final List<DeliveryRequest> deliveryRequest;
  final String? selectedRequest;

  ServiceState({
    required this.isAvailable,
    required this.isDelivering,
    required this.deliveryRequest,
    this.selectedRequest,
  });

  ServiceState copyWith({
    bool? isAvailable,
    bool? isDelivering,
    List<DeliveryRequest>? deliveryRequest,
    String? selectedRequest,
  }) {
    return ServiceState(
      isAvailable: isAvailable ?? this.isAvailable,
      isDelivering: isDelivering ?? this.isDelivering,
      deliveryRequest: deliveryRequest ?? this.deliveryRequest,
      selectedRequest:
          Utils.nullIsEmpty(selectedRequest ?? this.selectedRequest),
    );
  }

  ServiceState addDeliveryRequest(DeliveryRequest deliveryRequest) {
    return copyWith(
      deliveryRequest: [...this.deliveryRequest, deliveryRequest],
    );
  }

  @override
  List<Object?> get props => [
        isAvailable,
        isDelivering,
        deliveryRequest.map((e) => e.order.id + e.order.clientID).toList(),
        selectedRequest,
      ];
}

class ServiceCubit extends Cubit<ServiceState> {
  ServiceCubit()
      : super(ServiceState(
          isAvailable: false,
          isDelivering: false,
          deliveryRequest: [],
        ));

  void toggleAvailability(BuildContext context) async {
    if (state.isAvailable) {
      await RemoteMessages().unattachFromCells(Cache.attachedCells);
      Cache.attachedCells = [];

      await Notifications.notAvailable();
      await Backgrounds.stopAvailability();
    } else {
      RemoteMessages().setUpBackgroundMessageHandler();

      final location = await getLocation();
      if (location == null) return;

      final city = await DirectionRepository.getCityName(location);
      await Notifications.available(city: city);

      final cell = DirectionRepository.roundToSquareCenter(
          location.longitude, location.latitude, 30);
      final cellID = "zone-${cell.dy.round()}-${cell.dx.round()}";

      await RemoteMessages().attachToCell(cellID);
      print(cellID);
      Cache.attachedCells = [cellID];
      await Cache.setAvailabilityLocation(location);

      // await Backgrounds.schedulerAvailability();
    }

    emit(state.copyWith(isAvailable: !state.isAvailable));
  }

  static Future<LatLng?> getLocation() async {
    final refusedToUseLocation = !await GpsRepository().isPermitted() &&
        !await GpsRepository().requestPermission();

    if (refusedToUseLocation) {
      return null;
    } else {
      final coords = await GpsRepository().getCurrentPosition();
      if (coords == null) return null;
      return LatLng(coords.dy, coords.dx);
    }
  }

  void startDelivery(DeliveryRequest request) {}

  void unselectRequest() {
    emit(state.copyWith(selectedRequest: ""));
  }

  void init(BuildContext context) {
    emit(state.copyWith(
      deliveryRequest: Cache.deliveryRequests,
    ));

    RemoteMessages().listenToMessages((message, fromForground) async {
      if (!message.data.containsKey("type") ||
          message.data["type"] != "orderAccepted") return;

      if (Cache.availabilityLocation == null) return;

      if (fromForground) {
        final request =
            await handleAcceptedOrderNoti(message, Cache.availabilityLocation!);
        emit(state.addDeliveryRequest(request).copyWith(
              selectedRequest: request.order.id,
            ));
        return;
      } else {
        final order = Order.fromJson(jsonDecode(message.data["order"]));

        // keep checking until background task is done
        while (true) {
          final request = Cache.getDeliveryRequestData(order.id);
          if (request != null) {
            emit(state.addDeliveryRequest(request).copyWith(
                  selectedRequest: request.order.id,
                ));
            return;
          }
          await Future.delayed(Duration(seconds: 1));
        }
      }
    });
  }

  static Future<DeliveryRequest> handleAcceptedOrderNoti(
      RemoteMessage message, LatLng myLocation) async {
    final order = Order.fromJson(jsonDecode(message.data["order"]));

    final directions = await Future.wait([
      DirectionRepository.direction(order.sellerAddress, order.clientAddress),
      DirectionRepository.direction(myLocation, order.sellerAddress)
    ]);

    final request = DeliveryRequest(
      order: order,
      toClient: directions[0],
      toSeller: directions[1],
    );

    await Cache.saveDeliveryRequestData(request);

    return request;
  }
}
