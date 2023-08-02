import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:deliver/repository/cache.dart';
import 'package:deliver/repository/messages_remote.dart';

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

  Future<void> updateClient(DeliveryMan deliver) async {
    await Future.wait([
      Server.auth.currentUser!.updateDisplayName(deliver.name),
      Server.auth.currentUser!.updatePhotoURL(deliver.photo),
    ]);

    Server.auth.currentUser!.reload();

    emit(state.copyWith(deliveryMan: deliver));
    Cache.deliveryMan = deliver;
  }

  Future<void> logOut() async {
    await Server.auth.signOut();

    Cache.clear(); // this will force the entire app to be clear!
    emit(state.copyWith(deliveryMan: null));
  }
}
