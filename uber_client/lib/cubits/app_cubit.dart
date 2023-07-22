import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:uber_client/models/client.dart';

import '../repositories/cache.dart';
import '../repositories/messages_remote.dart';
import '../repositories/server.dart';

class AppState extends Equatable {
  Client? client;

  AppState({
    this.client,
  });

  AppState copyWith({
    Client? client,
  }) {
    return AppState(
      client: client ?? this.client,
    );
  }

  @override
  List<Object?> get props => [
        client?.id,
      ];
}

class AppCubit extends Cubit<AppState> {
  AppCubit() : super(AppState());

  Future<void> setUser(Client user) async {
    emit(state.copyWith(client: user));
    Cache.client = user;
    await deliveryManExists(user);
  }

  void removeUser() {
    Cache.client = null;
  }

  Future<void> deliveryManExists(Client client) async {
    if (!Cache.isFirstRun) return;
    final userID = client.id;
    final fcmToken = await RemoteMessages().getToken();

    await Server().assignNotiIDtoClient(
      clientID: userID,
      notiID: fcmToken,
    );
  }
}
