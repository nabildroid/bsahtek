import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uber_seller/cubits/app_cubit.dart';
import 'package:uber_seller/repository/server.dart';

import '../model/bag.dart';
import '../model/order.dart';
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

    // we get first from cache

    final cachedZones = Cache.zones;
    var inWithin = cachedZones.where((element) => element.quantities.keys.any(
          (key) => bagsIds.contains(key),
        ));

    if (inWithin.isNotEmpty) {
      final id = bags.first.id.toString();
      for (var element in inWithin) {
        if (element.quantities.containsKey(id)) {
          emit(state.copyWith(
            quantity: element.quantities[id] ?? 0,
          ));
          break;
        }
      }
    }

    // then from the server
    final zones = await Server().getZones(bagsIds);

    zones.forEach((element) => Cache.addZone(element));

    inWithin = zones.where((element) => element.quantities.keys.any(
          (key) => bagsIds.contains(key),
        ));

    if (inWithin.isNotEmpty) {
      final id = bags.first.id.toString();
      for (var element in inWithin) {
        if (element.quantities.containsKey(id)) {
          emit(state.copyWith(
            quantity: element.quantities[id] ?? 0,
          ));
          break;
        }
      }
    }
  }

  void syncPrevOrders() async {
    _stopListeningToOrders?.call();

    _stopListeningToOrders = await Server().listenToOrders(
      lastUpdated: Cache.lastUpdatedPrevOrders,
      onChange: (orders) async {
        for (var order in orders) {
          // if (Cache.lastUpdatedPrevOrders.isBefore(order.lastUpdate)) {
          //   // todo i think this is not needed!
          //   continue;
          // }
          await Cache.updatePrevOrder(order);
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
        if (order.expired) return;
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
    final filteredOrders = orders.where((element) => !element.expired).toList();

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
    if (order.expired) return;
    final bag = state.bags
        .firstWhere((element) => element.id.toString() == order.bagID);

    // todo i don't love this pattern
    useContext((ctx) async {
      final seller = ctx.read<AppCubit>().state.seller!;

      final acceptedOrder = order.accept(seller, bag);
      await Server().acceptOrder(acceptedOrder);

      emit(
        state.copyWith(
            runningOrders: state.runningOrders
                .where((element) => element != order)
                .toList()),
      );
    });
  }

  void addQuantity() async {
    if (state.bags.isEmpty) return;
    final id = state.bags.first.id.toString();
    final zones = Cache.zones;
    await Server().addQuantity(zones, id, 1);
    emit(state.copyWith(quantity: state.quantity + 1));
  }

  void removeQuantity(bool all) async {
    if (state.bags.isEmpty) return;
    final id = state.bags.first.id.toString();
    final zones = Cache.zones;

    final quantity = state.quantity;

    await Server().addQuantity(zones, id, all ? -quantity : -1);
    emit(state.copyWith(quantity: state.quantity + (all ? -quantity : -1)));
  }
}
