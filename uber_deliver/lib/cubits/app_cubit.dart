import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:uber_deliver/repository/cache.dart';
import 'package:uber_deliver/repository/messages_remote.dart';

import '../models/delivery_man.dart';
import '../repository/server.dart';

class AppState extends Equatable {
  DeliveryMan? deliveryMan;

  AppState({
    this.deliveryMan,
  });

  AppState copyWith({
    DeliveryMan? deliveryMan,
  }) {
    return AppState(
      deliveryMan: deliveryMan ?? this.deliveryMan,
    );
  }

  @override
  List<Object?> get props => [
        deliveryMan?.id,
      ];
}

class AppCubit extends Cubit<AppState> {
  AppCubit() : super(AppState());

  Future<void> setUser(DeliveryMan user) async {
    emit(state.copyWith(deliveryMan: user));
    Cache.deliveryMan = user;
    await deliveryManExists(user);
  }

  void removeUser() {
    Cache.deliveryMan = null;
  }

  Future<void> deliveryManExists(DeliveryMan deliveryMan) async {
    if (!Cache.isFirstRun) return;
    final userID = deliveryMan.id;
    final fcmToken = await RemoteMessages().getToken();

    await Server().assignNotiIDtoDeliveryMan(userID, fcmToken);
  }
}
