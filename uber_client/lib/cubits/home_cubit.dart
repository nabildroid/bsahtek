import 'dart:convert';
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uber_client/repositories/backgrounds.dart';

import '../models/bag.dart';
import '../models/client.dart';
import '../repositories/notifications.dart';
import '../models/order.dart';
import '../repositories/cache.dart';
import '../repositories/messages_remote.dart';
import '../repositories/server.dart';

class HomeState extends Equatable {
  Order? runningOrder;
  final bool focusOnRunningOrder;

  HomeState({
    this.runningOrder,
    this.focusOnRunningOrder = false,
  });

  HomeState copyWith({
    bool? focusOnRunningOrder,
    bool? isRunningVisible = false,
  }) {
    return HomeState(
      runningOrder: runningOrder,
      focusOnRunningOrder: focusOnRunningOrder ?? this.focusOnRunningOrder,
    );
  }

  HomeState killRunningOrder() {
    return copyWith()..runningOrder = null;
  }

  @override
  List<Object?> get props => [
        runningOrder?.id ?? "runningOrders",
        focusOnRunningOrder,
      ];
}

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomeState());

  @override
  void onChange(Change<HomeState> change) {
    super.onChange(change);
    print(change);
  }

  bool inited = false;
  Future<void> init({Client? client}) async {
    if (inited) return;
    inited = true;

    emit(state.copyWith()..runningOrder = Cache.runningOrder);

    RemoteMessages().setUpBackgroundMessageHandler();
    _subscribeToOnAppNotification();

    if (Cache.runningOrder != null) {
      focusOnRunningOrder();
    }
  }

  void _subscribeToOnAppNotification() {
    Notifications.onClick((type) {
      if (type == 'delivery') {
        focusOnRunningOrder();
      }
    });

    RemoteMessages().listenToMessages((event) async {
      if (!event.data.containsKey("type")) return;

      if (event.data["type"] == "delivery_end") {
        await Backgrounds.firebaseMessagingBackgroundHandler(event);
        emit(state.killRunningOrder());
        return;
      }

      if (event.data["type"] == "delivery_start") {
        final order = Order.fromJson(jsonDecode(event.data["order"]));

        Cache.runningOrder = order;
        emit(state.copyWith(focusOnRunningOrder: true)..runningOrder = order);

        await Notifications.deliveryOnProgress(order.bagName);
      }
    });
  }

  void focusOnRunningOrder() {
    emit(state.copyWith(focusOnRunningOrder: false));
    Future.delayed(Duration(milliseconds: 100), () {
      emit(state.copyWith(focusOnRunningOrder: true));
    });
  }

  void unFocusOnRunning() {
    emit(state.copyWith(focusOnRunningOrder: false, isRunningVisible: false));
  }

  Future<void> orderBag(Order order) async {
    await Server().orderBag(order);
  }

  void recheckRunningOrder() async {
    if (Cache.runningOrder == null) {
      unFocusOnRunning();

      emit(state.killRunningOrder());
      return;
    } else {
      emit(state.copyWith()..runningOrder = Cache.runningOrder);
    }
  }
}
