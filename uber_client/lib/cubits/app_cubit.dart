import 'dart:convert';
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/bag.dart';
import '../models/client.dart';
import '../models/order.dart';
import '../repositories/cache.dart';
import '../repositories/messages_remote.dart';
import '../repositories/server.dart';

class AppState extends Equatable {
  final String? fCMToken;
  final Client? client;

  const AppState({this.fCMToken, this.client});

  AppState copyWith({
    String? fCMToken,
    Client? client,
  }) {
    return AppState(
      fCMToken: fCMToken ?? this.fCMToken,
      client: client ?? this.client,
    );
  }

  @override
  List<Object?> get props => [
        fCMToken,
        client?.id,
      ];
}

class AppCubit extends Cubit<AppState> {
  final RemoteMessages remoteMessages;

  AppCubit({
    required this.remoteMessages,
  }) : super(const AppState());

  bool inited = false;

  @override
  void onChange(Change<AppState> change) {
    super.onChange(change);
    print(change);
  }

  Future<void> init({Client? client}) async {
    if (inited) return;
    inited = true;

    var currentClient = client ?? Cache.currentClient;
    Cache.currentClient = currentClient;

    emit(state.copyWith(client: currentClient));

    if (Cache.isFirstRun) {
      final fCMToken = await remoteMessages.initMessages();
      await Server().assignNotiIDtoClient(
        notiID: fCMToken,
        clientID: currentClient!.id,
      );
    }
    remoteMessages.setUpBackgroundMessageHandler();
    _subscribeToOnAppNotification();
  }

  void _subscribeToOnAppNotification() {
    remoteMessages.listenToMessages((event) {});
  }

  Future<void> orderBag(Order order) async {
    await Server().orderBag(order);
  }
}
