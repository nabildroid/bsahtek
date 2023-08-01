import 'dart:convert';
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uber_client/repositories/backgrounds.dart';
import 'package:uber_client/utils/constants.dart';

import '../models/bag.dart';
import '../models/client.dart';
import '../repositories/notifications.dart';
import '../models/order.dart';
import '../repositories/cache.dart';
import '../repositories/messages_remote.dart';
import '../repositories/server.dart';
import '../screens/running.dart';
import '../utils/firebase.dart';
import '../widgets/shared/ratingdialog.dart';

class HomeState extends Equatable {
  Order? runningOrder;
  final bool focusOnRunningOrder;

  final List<Bag> liked;
  final List<Order> prevOrders;

  final DateTime? throttlingReservation;

  HomeState({
    this.runningOrder,
    this.focusOnRunningOrder = false,
    required this.liked,
    required this.prevOrders,
    this.throttlingReservation,
  });

  HomeState copyWith({
    bool? focusOnRunningOrder,
    bool? isRunningVisible = false,
    List<Bag>? liked,
    List<Order>? prevOrders,
    DateTime? throttlingReservation,
  }) {
    return HomeState(
      runningOrder: runningOrder,
      focusOnRunningOrder: focusOnRunningOrder ?? this.focusOnRunningOrder,
      liked: liked ?? this.liked,
      prevOrders: prevOrders ?? this.prevOrders,
      throttlingReservation:
          throttlingReservation ?? this.throttlingReservation,
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
        prevOrders.map((e) => e.id + e.lastUpdate.toIso8601String()).toList(),
        throttlingReservation,
      ];
}

class HomeCubit extends Cubit<HomeState> {
  HomeCubit()
      : super(HomeState(
          liked: Cache.likedBags,
          prevOrders: Cache.prevOrders,
          throttlingReservation: Cache.throttlingReservation,
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

    if (Cache.runningOrder != null && Cache.runningOrder!.expired == false) {
      emit(state.copyWith()..runningOrder = Cache.runningOrder);

      if (Cache.runningOrder != null) {
        subscribeToRunningOrder();
      }
    }

    RemoteMessages().setUpBackgroundMessageHandler();
    _subscribeToOnAppNotification();
    syncPrevOrders();

    if (Cache.runningOrder != null && Cache.runningOrder!.expired == false) {
      final running = Cache.runningOrder!;
      if (running.isPickup) {
        await Notifications.orderAccepted(true);
      } else {
        await Notifications.deliveryOnProgress(running.bagName);
      }
      focusOnRunningOrder();
    } else {
      Cache.runningOrder = null;
      await Notifications.clear();
    }
  }

  void _subscribeToOnAppNotification() {
    Notifications.onClick((type, payload) async {
      if (type == 'rate') {
        final orderID = payload["orderID"];
        final bagName = payload["bagName"];
        handleGoingToRate(orderID, bagName);
        return;
      }

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

        if (!await Backgrounds.firebaseMessagingBackgroundHandler(event))
          return;

        emit(state.copyWith(focusOnRunningOrder: true)..runningOrder = order);
        useContext((ctx) => RunningScreen.go(order));
        tobeDisposed["runningOrder"]?.call();
        subscribeToRunningOrder();

        return;
      }

      if (event.data["type"] == "order_accepted") {
        tobeDisposed["runningOrder"]?.call();
        var order = Order.fromJson(jsonDecode(event.data["order"]));

        if (!await Backgrounds.firebaseMessagingBackgroundHandler(event))
          return;

        emit(state.copyWith()..runningOrder = order);
        subscribeToRunningOrder();
        return;
      }
    });
  }

  void handleGoingToRate(String orderID, String bagName) {
    useContext((ctx) {
      showDialog(
          context: ctx,
          builder: (ctx) => RatingDialog(
              title: bagName,
              description: "how ${bagName} was",
              onRated: (id) {
                Server().rate(orderID: orderID, rating: id);
              }));
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
    // if (state.throttlingReservation?.isAfter(DateTime.now()) ?? false) {
    //   return;
    // }

    final throttling =
        DateTime.now().add(Constants.pauseReservingAfterReservation);

    emit(state.copyWith(throttlingReservation: throttling));

    await Server().orderBag(order);
    syncPrevOrders(force: true);
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
    final liked = List<Bag>.from(state.liked); // Create a new list
    if (isLiked(bag.id)) {
      liked.removeWhere((element) => element.id == bag.id);
    } else {
      liked.add(bag);
    }
    Cache.likedBags = liked;
    emit(state.copyWith(liked: liked)); // Pass the new list to the new state
  }

  void syncPrevOrders({bool force = false}) {
    if (!force &&
        Cache.prevOrders.isNotEmpty &&
        Cache.prevOrders.every((element) => !element.inProgress)) {
      // already in synced, assuming the app is used only one device
      return;
    }

    tobeDisposed["prevOrders"]?.call();
    tobeDisposed["prevOrders"] = Server()
        .listenToPrevOrders(Cache.lastUpdatePrevOrders, (changes) async {
      // if non of the orders has an active order then sync and dispose, otherwise keep listening
      // but what about pusing an order

      final allPrevOrders = List<Order>.from(state.prevOrders);

      // check by id, if the changes contains an order that is already in the list then replace it
      for (var change in changes) {
        final index =
            allPrevOrders.indexWhere((element) => element.id == change.id);
        if (index != -1) {
          allPrevOrders[index] = change;
        } else {
          allPrevOrders.add(change);
        }
      }

      emit(state.copyWith(prevOrders: allPrevOrders));
      await Cache.setPrevOrders(allPrevOrders);

      if (allPrevOrders.any((element) => element.inProgress)) return;

      // tobeDisposed["prevOrders"]?.call(); // todo, this is dirty fix, we need this line
    });
  }

  Future<String?> showEnterYourNameDialog() {
    final controller = TextEditingController();
    return showDialog<String>(
      context: freshContext!,
      builder: (context) => AlertDialog(
        title: Text("Enter your name"),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: "Enter your name",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(controller.text);
            },
            child: Text("ok"),
          ),
        ],
      ),
    );
  }
}
