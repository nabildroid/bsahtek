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
import 'package:uber_deliver/screens/runningNoti.dart';

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

  BuildContext? freshContext;

  List<void Function(BuildContext context)> waitingForContext = [];

  void setContext(BuildContext context) {
    freshContext = context;
    for (var element in waitingForContext) {
      element(context);
    }
    waitingForContext.clear();
  }

  void useContext(void Function(BuildContext context) callback) {
    if (freshContext != null) {
      return callback(freshContext!);
    }
    waitingForContext.add((context) => context);
  }

  void toggleAvailability() async {
    if (state.isAvailable) {
      await RemoteMessages().unattachFromCells(Cache.attachedCells);
      Cache.attachedCells = [];

      await Notifications.notAvailable();
      await Backgrounds.stopAvailability();
    } else {
      emit(state.copyWith(loadingAvailability: true));
      RemoteMessages().setUpBackgroundMessageHandler();

      final location = await GpsRepository.getLocation();
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

  void killDelivery() async {
    await Notifications.notAvailable();
    emit(state.killRunningRequst().copyWith(isAvailable: false));
    Cache.runningRequest = null;
    Cache.setAvailabilityLocation(null);
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
    useContext((context) => RunningScreen.go(context, request));

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
    if (state.runningRequest != null) {
      useContext((context) => RunningScreen.go(context, state.runningRequest!));
    }
  }

  // make sure this is going to be called only once
  void init() async {
    print("Initing the cubits");

    initListener();

    emit(state.copyWith(
      runningRequest: Cache.runningRequest,
      focusOnRunning: true,
      isAvailable: Cache.availabilityLocation != null,
    ));

    final needToShowRunning = Cache.runningRequest != null;
    if (needToShowRunning) {
      useContext((context) => RunningScreen.go(context, Cache.runningRequest!));
      await Backgrounds.stopRunning();
      await Backgrounds.schedulerRunning();
    } else {
      final isAlreadyAvailable = Cache.availabilityLocation != null;
      if (isAlreadyAvailable) {
        final city =
            await DirectionRepository.getCityName(Cache.availabilityLocation!);
        await Notifications.available(city: city);
        await Backgrounds.stopAvailability();
        await Backgrounds.schedulerAvailability();
      } else {
        // stop everything just in case
        await Backgrounds.stopAvailability();
        await Notifications.notAvailable();
        await RemoteMessages().unattachFromCells(Cache.attachedCells);
      }
    }
  }

  void initListener() {
    RemoteMessages().listenToMessages((message, fromForground) async {
      if (!message.data.containsKey("type") ||
          message.data["type"] != "orderAccepted") return;

      if (Cache.availabilityLocation == null) return;

      if (fromForground) {
        final request =
            await handleAcceptedOrderNoti(message, Cache.availabilityLocation!);

        emit(state.copyWith(
          selectedRequest: request,
        ));
        useContext(
            (ctx) => Navigator.of(ctx).push(RunningNotiScreen.go(request)));
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

            useContext(
                (ctx) => Navigator.of(ctx).push(RunningNotiScreen.go(request)));
            return;
          }
          await Future.delayed(Duration(seconds: 1));
        }
      }
    });

    Notifications.onClick((type) {
      if (type == "onMission") {
        if (state.focusOnRunning == false) {
          emit(state.copyWith(focusOnRunning: true));
          useContext(
              (context) => RunningScreen.go(context, state.runningRequest!));
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
