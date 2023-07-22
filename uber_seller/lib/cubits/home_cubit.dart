import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:uber_seller/repository/server.dart';

import '../model/bag.dart';
import '../model/order.dart';
import '../model/seller.dart';
import '../repository/cache.dart';
import '../repository/messages_remote.dart';
import '../screens/running_order.dart';

class HomeState extends Equatable {
  final List<Bag> bags;

  final List<Order> runningOrders;
  final List<Order> prevOrders;

  Order? orderToBePickedUp;

  final int quantity;

  HomeState({
    this.runningOrders = const [],
    this.prevOrders = const [],
    this.quantity = 0,
    this.orderToBePickedUp,
    required this.bags,
  });

  HomeState copyWith({
    List<Order>? runningOrders,
    List<Order>? prevOrders,
    int? quantity,
    List<Bag>? bags,
  }) {
    return HomeState(
      runningOrders: runningOrders ?? this.runningOrders,
      prevOrders: prevOrders ?? this.prevOrders,
      quantity: quantity ?? this.quantity,
      bags: bags ?? this.bags,
    );
  }

  HomeState pushRunningOrder(Order order) {
    final list = [...runningOrders, order];
    list.sort((a, b) => a.lastUpdate.compareTo(b.lastUpdate));

    return copyWith(runningOrders: list);
  }

  @override
  List<Object?> get props => [
        ...runningOrders.map((e) => e.id),
        ...prevOrders.map((e) => e.id + e.lastUpdate.toString()),
        quantity,
        orderToBePickedUp?.id ?? "orderToBePickedUp",
      ];
}

class HomeCubit extends Cubit<HomeState> {
  VoidCallback? _stopListeningToOrders;

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

  HomeCubit()
      : super(HomeState(
          bags: [],
        ));

  Future<void> init() async {
    await fetchBagsAndQuantities();

    syncPrevOrders();
    RemoteMessages().setUpBackgroundMessageHandler();
    _subscribeToOnAppNotification();
    handlePendingRunningOrders();
  }

  Future<void> fetchBagsAndQuantities() async {
    final bags = await Server().getBags();
    emit(state.copyWith(bags: bags));

    final bagsIds = bags.map((e) => e.id.toString()).toList();
    final quantities = await Server().getQuantities(bagsIds);

    Cache.quantities = quantities;

    emit(state.copyWith(
      quantity: quantities[bags.first.id] ?? 0,
    ));
  }

  void syncPrevOrders() async {
    _stopListeningToOrders?.call();

    _stopListeningToOrders = await Server().listenToOrders(
      lastUpdated: Cache.lastUpdatedPrevOrders,
      onChange: (orders) {
        for (var order in orders) {
          if (Cache.lastUpdatedPrevOrders.isBefore(order.lastUpdate)) {
            // todo i think this is not needed!
            continue;
          }
          Cache.updatePrevOrder(order);
        }

        emit(state.copyWith(prevOrders: Cache.prevOrders));
      },
    );
  }

  void _subscribeToOnAppNotification() {
    RemoteMessages().listenToMessages((event) {
      if (!event.data.containsKey("type")) return;

      if (event.data["type"] == "delivery_need_to_pickup") {
        return _deliveryNeedToPickup(event.data["orderID"]);
      } else if (event.data["type"] == "new_order") {
        final order = Order.fromJson(jsonDecode(event.data["order"]));
        emit(state.pushRunningOrder(order));
        useContext((ctx) => RunningOrder.go(ctx, order: order, index: 1));
      }
    });
  }

  void _deliveryNeedToPickup(String orderID) {
    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      final allOrders = [...state.prevOrders, ...state.runningOrders];
      if (allOrders.isEmpty) return;
      try {
        final order = allOrders.firstWhere((element) => element.id == orderID);

        emit(state.copyWith()..orderToBePickedUp = order);
        useContext((ctx) => RunningOrder.go(
              ctx,
              order: order,
              index: 1,
              isPickup: true,
            ));
        timer.cancel();
      } catch (e) {
        return;
      }
    });
  }

  void handlePendingRunningOrders() async {
    await Cache.recache();

    final orders = Cache.runningOrders;

    // filter older than 1 min
    final now = DateTime.now();
    final filteredOrders = orders.where((element) {
      final diff = now.difference(element.createdAt);
      return diff.inMinutes < 1;
    }).toList();

    emit(state.copyWith(runningOrders: filteredOrders));
    for (var i = 0; i < filteredOrders.length; i++) {
      final order = filteredOrders[i];

      useContext((ctx) => RunningOrder.go(ctx, order: order, index: i));
    }
  }

  void handOver(Order order) async {
    await Server().handOver(order);
  }

  void acceptOrder(Order order) async {
    final acceptedOrder = order.accept();
    await Server().acceptOrder(acceptedOrder);

    emit(
      state.copyWith(
          runningOrders: state.runningOrders
              .where((element) => element != order)
              .toList()),
    );
  }

  void addQuantity() {}

  void removeQuantity(bool all) {
    final quantity = state.quantity;
    if (all) {
      emit(state.copyWith(quantity: 0));
    } else {
      emit(state.copyWith(quantity: max(0, quantity - 1)));
    }
  }
}
