import 'dart:convert';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:deliver/repository/background.dart';
import 'package:deliver/repository/gps.dart';
import 'package:deliver/repository/messages_remote.dart';
import 'package:deliver/repository/notifications.dart';
import 'package:deliver/screens/running.dart';
import 'package:deliver/screens/runningNoti.dart';

import '../models/delivery_request.dart';
import '../models/order.dart';
import '../repository/cache.dart';
import '../repository/direction.dart';
import '../repository/server.dart';
import '../utils/utils.dart';

class ServiceState extends Equatable {
  bool isAvailable;

  bool loadingAvailability;
  DeliveryRequest? runningRequest;
  bool focusOnRunning;

  List<Order> deliveredOrders;
  DeliveryRequest? selectedRequest;

  ServiceState(
      {required this.isAvailable,
      this.selectedRequest,
      this.runningRequest,
      this.loadingAvailability = false,
      this.focusOnRunning = false,
      required this.deliveredOrders});

  ServiceState copyWith(
      {bool? isAvailable,
      DeliveryRequest? selectedRequest,
      bool? loadingAvailability,
      DeliveryRequest? runningRequest,
      bool? focusOnRunning,
      List<Order>? deliveredOrders}) {
    return ServiceState(
      isAvailable: isAvailable ?? this.isAvailable,
      runningRequest: runningRequest ?? this.runningRequest,
      selectedRequest: selectedRequest ?? this.selectedRequest,
      loadingAvailability: loadingAvailability ?? this.loadingAvailability,
      focusOnRunning: focusOnRunning ?? this.focusOnRunning,
      deliveredOrders: deliveredOrders ?? this.deliveredOrders,
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
        deliveredOrders.map((e) => e.id + e.lastUpdate.toString()).toList()
      ];
}

class ServiceCubit extends Cubit<ServiceState> {
  ServiceCubit()
      : super(ServiceState(
          isAvailable: false,
          deliveredOrders: [],
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

      attachToLocation(location);
      await Cache.setAvailabilityLocation(location);

      await Backgrounds.schedulerAvailability();
    }

    emit(state.copyWith(
      isAvailable: !state.isAvailable,
      loadingAvailability: false,
    ));
  }

  Future<void> killDelivery() async {
    await Notifications.notAvailable();
    emit(state.killRunningRequst().copyWith(isAvailable: false));
    Cache.runningRequest = null;
    Cache.trackedToSeller = null;
    Cache.setAvailabilityLocation(null);
    await Backgrounds.stopRunning();
  }

  void finishDelivery() async {
    await killDelivery();

    await fetchDeliveredOrders();
    // todo schedule notification to congratulate the deliver
    // do hard fetch for the old tracks and orders to update the history
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

    emit(state.copyWith(
      runningRequest: Cache.runningRequest,
      focusOnRunning: true,
      isAvailable:
          Cache.runningRequest == null && Cache.availabilityLocation != null,
    ));

    fetchDeliveredOrders();
    final needToShowRunning = Cache.runningRequest != null;

    if (needToShowRunning) {
      Future.delayed(Duration(seconds: 1), () {
        useContext(
            (context) => RunningScreen.go(context, state.runningRequest!));
      });

      await Backgrounds.stopRunning();
      await Backgrounds.schedulerRunning();
      await Notifications.onMission(
        clientName: Cache.runningRequest!.order.clientName,
        distance: Cache.runningRequest!.toClient.distance +
            Cache.runningRequest!.toSeller.distance,
        duration: Cache.runningRequest!.toClient.duration +
            Cache.runningRequest!.toSeller.duration,
        city: Cache.runningRequest!.order.clientTown,
      );
    } else {
      final isAlreadyAvailable = Cache.availabilityLocation != null;
      if (isAlreadyAvailable) {
        attachToLocation(Cache.availabilityLocation!);

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

    initListener();
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
        // todo this might be infinit when the order is expired
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

    if (order.expired) throw Exception("Order is expired");

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

  Future<void> fetchDeliveredOrders() async {
    emit(state.copyWith(deliveredOrders: Cache.deliveredOrders));
    final updatedOrders =
        await Server().getDeliveredOrders(Cache.lastUpdatedDeliveredOrders);

    for (var update in updatedOrders) {
      await Cache.updateDeliveredOrders(update);
    }

    emit(state.copyWith(deliveredOrders: Cache.deliveredOrders));
  }

  void attachToLocation(LatLng location) async {
    final cell = DirectionRepository.roundToSquareCenter(
        location.longitude, location.latitude, 30);
    final cellID = "zone-${cell.dy.round()}-${cell.dx.round()}";
    print("attaching to $cellID");
    await RemoteMessages().attachToCell(cellID);
    Cache.attachedCells = [cellID];
  }
}
