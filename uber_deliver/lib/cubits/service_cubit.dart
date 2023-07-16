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
  bool isAvailable;

  bool loadingAvailability;
  DeliveryRequest? runningRequest;
  bool focusOnRunning;

  DeliveryRequest? selectedRequest;

  ServiceState({
    required this.isAvailable,
    this.selectedRequest,
    this.runningRequest,
    this.loadingAvailability = false,
    this.focusOnRunning = false,
  });

  ServiceState copyWith({
    bool? isAvailable,
    DeliveryRequest? selectedRequest,
    bool? loadingAvailability,
    DeliveryRequest? runningRequest,
    bool? focusOnRunning,
  }) {
    return ServiceState(
      isAvailable: isAvailable ?? this.isAvailable,
      runningRequest: runningRequest ?? this.runningRequest,
      selectedRequest: selectedRequest ?? this.selectedRequest,
      loadingAvailability: loadingAvailability ?? this.loadingAvailability,
      focusOnRunning: focusOnRunning ?? this.focusOnRunning,
    );
  }

  ServiceState unselectRequest() {
    return copyWith()..selectedRequest = null;
  }

  ServiceState killRunningRequst() {
    return copyWith()..runningRequest = null;
  }

  @override
  List<Object?> get props => [
        isAvailable,
        runningRequest?.order.id ?? "OrderID",
        selectedRequest?.order.id ?? "selectedOrderID",
        loadingAvailability,
        focusOnRunning,
      ];
}

class ServiceCubit extends Cubit<ServiceState> {
  ServiceCubit()
      : super(ServiceState(
          isAvailable: false,
        ));

  void toggleAvailability(BuildContext context) async {
    if (state.isAvailable) {
      await RemoteMessages().unattachFromCells(Cache.attachedCells);
      Cache.attachedCells = [];

      await Notifications.notAvailable();
      await Backgrounds.stopAvailability();
    } else {
      emit(state.copyWith(loadingAvailability: true));
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

    emit(state.copyWith(
      isAvailable: !state.isAvailable,
      loadingAvailability: false,
    ));
  }

  static Future<LatLng?> getLocation() async {
    final refusedToUseLocation = !await GpsRepository.isPermitted() &&
        !await GpsRepository.requestPermission();

    if (refusedToUseLocation) {
      return null;
    } else {
      final coords = await GpsRepository.getCurrentPosition();
      if (coords == null) return null;
      return LatLng(coords.dy, coords.dx);
    }
  }

  void killDelivery() async {
    await Notifications.notAvailable();
    emit(state.killRunningRequst());
    Cache.runningRequest = null;
    await Backgrounds.stopRunning();
  }

  void startDelivery(DeliveryRequest request) async {
    await Notifications.notAvailable();
    await Backgrounds.stopAvailability();

    await Notifications.onMission(
      city: request.order.clientTown,
      clientName: request.order.clientName,
      distance: request.toClient.distance,
      duration: request.toClient.duration,
    );

    await Backgrounds.schedulerRunning();

    await RemoteMessages().unattachFromCells(Cache.attachedCells);
    Cache.runningRequest = request;

    emit(state.copyWith(
      isAvailable: false,
      runningRequest: request,
      selectedRequest: null,
    ));
  }

  void unselectRequest() {
    emit(state.unselectRequest());
  }

  void unfocusFromRunning() {
    emit(state.copyWith(focusOnRunning: false));
  }

  void focusOnRunning() {
    emit(state.copyWith(focusOnRunning: true));
  }

  void init(BuildContext context) {
    print("Initigng the service CUbit");

    bool keepWorking = true;
    // for this hack to work, it init must be the last one in the loading Init phase!
    Future.delayed(Duration(milliseconds: 500)).then((_) {
      if (keepWorking == false) return;
      emit(state.copyWith(
        runningRequest: Cache.runningRequest,
        focusOnRunning: true,
      ));
    });

    RemoteMessages().listenToMessages((message, fromForground) async {
      if (!message.data.containsKey("type") ||
          message.data["type"] != "orderAccepted") return;

      if (Cache.availabilityLocation == null) return;
      keepWorking = false;

      if (fromForground) {
        final request =
            await handleAcceptedOrderNoti(message, Cache.availabilityLocation!);

        emit(state.copyWith(
          selectedRequest: request,
        ));

        return;
      } else {
        final order = Order.fromJson(jsonDecode(message.data["order"]));

        // keep checking until background task is done
        while (true) {
          final request = Cache.getDeliveryRequestData(order.id);
          if (request != null) {
            emit(state.copyWith(
              selectedRequest: request,
            ));
            return;
          }
          await Future.delayed(Duration(seconds: 1));
        }
      }
    });

    Notifications.onClick((type) {
      if (type == "onMission") {
        if (state.focusOnRunning == false) {
          emit(state.copyWith(
            focusOnRunning: true,
          ));
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
