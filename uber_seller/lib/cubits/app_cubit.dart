import 'dart:convert';
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:uber_seller/repository/server.dart';

import '../model/order.dart';
import '../model/seller.dart';
import '../repository/cache.dart';
import '../repository/messages_remote.dart';

class AppState extends Equatable {
  final String? fCMToken;
  final Seller? user;

  final List<Order> runningOrders;
  final List<Order> prevOrders;

  final int quantity;

  const AppState({
    this.fCMToken,
    this.user,
    this.runningOrders = const [],
    this.prevOrders = const [],
    this.quantity = 0,
  });

  AppState copyWith({
    String? fCMToken,
    Seller? user,
    List<Order>? runningOrders,
    List<Order>? prevOrders,
    int? quantity,
  }) {
    return AppState(
      fCMToken: fCMToken ?? this.fCMToken,
      user: user ?? this.user,
      runningOrders: runningOrders ?? this.runningOrders,
      prevOrders: prevOrders ?? this.prevOrders,
      quantity: quantity ?? this.quantity,
    );
  }

  AppState pushRunningOrder(Order order) {
    final list = [...runningOrders, order];
    list.sort((a, b) => a.lastUpdate.compareTo(b.lastUpdate));

    return copyWith(runningOrders: list);
  }

  @override
  List<Object?> get props => [
        fCMToken,
        user?.id,
        ...runningOrders.map((e) => e.id),
        ...prevOrders.map((e) => e.id + e.lastUpdate.toString()),
        quantity,
      ];
}

class AppQubit extends Cubit<AppState> {
  final Cache cache;
  final RemoteMessages remoteMessages;

  VoidCallback? _stopListeningToOrders;

  AppQubit({
    required this.cache,
    required this.remoteMessages,
  }) : super(AppState());

  Future<void> init() async {
    const userID = "HNcUoKLtz6tOs5U7X98E";
    final isNewStart = cache.isFirstRun;
    Seller? currentUser = cache.user;

    cache.user = currentUser;
    emit(state.copyWith(
      user: currentUser,
      quantity: cache.quantities[currentUser?.bags.first.id] ?? 0,
    ));

    await fetchFrechSellerAndQuantities(userID);
    if (isNewStart) {
      final fCMToken = await remoteMessages.initMessages();
      await Server().assignNotiIDtoSeller(
        notiID: fCMToken,
        sellerID: userID,
      );
    }
    syncPrevOrders(userID);
    remoteMessages.setUpBackgroundMessageHandler();
    _subscribeToOnAppNotification();
    handlePendingRunningOrders();
  }

  Future<void> fetchFrechSellerAndQuantities(String sellerID) async {
    final seller = await Server().getSeller(sellerID);
    emit(state.copyWith(user: seller));

    final quantities = await Server()
        .getQuantities(seller.bags.map((e) => e.id.toString()).toList());
    cache.user = seller;
    cache.quantities = quantities;

    emit(state.copyWith(
      quantity: quantities[seller.bags.first.id] ?? 0,
    ));
  }

  void syncPrevOrders(String sellerID) async {
    _stopListeningToOrders?.call();

    _stopListeningToOrders = await Server().listenToOrders(
      sellerID: sellerID,
      lastUpdated: cache.lastUpdatedPrevOrders,
      onChange: (orders) {
        for (var order in orders) {
          if (cache.lastUpdatedPrevOrders.isBefore(order.lastUpdate)) {
            // todo i think this is not needed!
            continue;
          }
          cache.updatePrevOrder(order);
        }

        emit(state.copyWith(prevOrders: cache.prevOrders));
      },
    );
  }

  void _subscribeToOnAppNotification() {
    remoteMessages.listenToMessages((event) {
      final order = Order.fromJson(jsonDecode(event.data["order"]));
      emit(state.pushRunningOrder(order));
    });
  }

  void changeTheme(bool isDarkMode) {
    emit(AppState());
  }

  void handlePendingRunningOrders() async {
    await cache.recache();

    final orders = cache.runningOrders;

    // filter older than 1 min
    final now = DateTime.now();
    final filteredOrders = orders.where((element) {
      final diff = now.difference(element.createdAt);
      return diff.inMinutes < 1;
    }).toList();

    emit(state.copyWith(runningOrders: filteredOrders));
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
