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
import '../screens/running.dart';
import '../utils/firebase.dart';

class HomeState extends Equatable {
  Order? runningOrder;
  final bool focusOnRunningOrder;

  final List<Bag> liked;
  final List<Order> prevOrders;

  HomeState({
    this.runningOrder,
    this.focusOnRunningOrder = false,
    required this.liked,
    required this.prevOrders,
  });

  HomeState copyWith({
    bool? focusOnRunningOrder,
    bool? isRunningVisible = false,
    List<Bag>? liked,
    List<Order>? prevOrders,
  }) {
    return HomeState(
      runningOrder: runningOrder,
      focusOnRunningOrder: focusOnRunningOrder ?? this.focusOnRunningOrder,
      liked: liked ?? this.liked,
      prevOrders: prevOrders ?? this.prevOrders,
    );
  }

  HomeState killRunningOrder() {
    return copyWith()..runningOrder = null;
  }

  @override
  List<Object?> get props => [
        runningOrder?.id ?? "runningOrders",
        focusOnRunningOrder,
        liked.map((e) => e.id).toList(),
        prevOrders.map((e) => e.id).toList(),
      ];
}

class HomeCubit extends Cubit<HomeState> {
  HomeCubit()
      : super(HomeState(
          liked: Cache.likedBags,
          prevOrders: Cache.prevOrders,
        ));

  Map<String, VoidCallback> tobeDisposed = {};

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

    if (Cache.runningOrder != null) {
      subscribeToRunningOrder();
    }

    RemoteMessages().setUpBackgroundMessageHandler();
    _subscribeToOnAppNotification();

    if (Cache.runningOrder != null) {
      final running = Cache.runningOrder!;
      if (running.isPickup) {
        await Notifications.orderAccepted(true);
      } else {
        await Notifications.deliveryOnProgress(running.bagName);
      }
      focusOnRunningOrder();
    } else {
      await Notifications.clear();
    }
  }

  void _subscribeToOnAppNotification() {
    Notifications.onClick((type) async {
      if (type == 'delivery') {
        focusOnRunningOrder();

        return;
      }

      if (type == 'orderAccepted') {
        // the background handler may take some time to update the running order
        for (var i = 0; i < 10; i++) {
          await Future.delayed(Duration(milliseconds: 100));
          if (Cache.runningOrder != null) break;
        }

        if (Cache.runningOrder == null) return;

        emit(state.copyWith()..runningOrder = Cache.runningOrder);
        focusOnRunningOrder();

        return;
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

        await Backgrounds.firebaseMessagingBackgroundHandler(event);

        emit(state.copyWith(focusOnRunningOrder: true)..runningOrder = order);
        useContext((ctx) => RunningScreen.go(order));
        tobeDisposed["runningOrder"]?.call();
        subscribeToRunningOrder();

        return;
      }

      if (event.data["type"] == "order_accepted") {
        tobeDisposed["runningOrder"]?.call();

        final data = FirestoreUtils.goodJson(
          jsonDecode(event.data["order"]),
        );

        final order = Order.fromJson(data);

        await Backgrounds.firebaseMessagingBackgroundHandler(event);

        emit(state.copyWith()..runningOrder = order);
        subscribeToRunningOrder();
        return;
      }
    });
  }

  void focusOnRunningOrder() {
    if (Cache.runningOrder?.isPickup == true) return;
    emit(state.copyWith(focusOnRunningOrder: false));
    Future.delayed(Duration(milliseconds: 100), () {
      emit(state.copyWith(focusOnRunningOrder: true));
      useContext(
        (ctx) => Navigator.of(ctx).push(RunningScreen.go(Cache.runningOrder!)),
      );
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

  void subscribeToRunningOrder() {
    final order = Cache.runningOrder!;
    tobeDisposed["runningOrder"] = (Server().listenToOrder(order.id, (order) {
      if (order.isDelivered == true) {
        emit(state.killRunningOrder());

        tobeDisposed["runningOrder"]?.call();
        Cache.runningOrder = null;
        Notifications.clear();
      }
    }));
  }

  @override
  close() async {
    for (var element in tobeDisposed.values) {
      element();
    }
    super.close();
  }

  bool isLiked(int bagID) {
    return state.liked.any((element) => element.id == bagID);
  }

  void toggleLiked(Bag bag) {
    final liked = state.liked;
    if (isLiked(bag.id)) {
      liked.removeWhere((element) => element.id == bag.id);
    } else {
      liked.add(bag);
    }
    Cache.likedBags = liked;
    emit(state.copyWith(liked: liked));
  }
}
