import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:bsahtak/models/client.dart';

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
        client?.toJson(),
      ];
}

class AppCubit extends Cubit<AppState> {
  AppCubit() : super(AppState());

  Future<void> setUser(Client user) async {
    emit(state.copyWith(client: user));
    Cache.client = user;

    if (user.isActive == false || user.phone.isEmpty) {
      keepRecheckingUser(forceFirst: false);
    }

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

  VoidCallback? userChecker;
  VoidCallback? userChanger;

  void keepRecheckingUser({forceFirst = true}) {
    userChanger?.call();
    userChecker?.call();

    void checker(Timer? timer) {
      userChanger = Server().onUserChange(
        (client) {
          userChanger?.call();

          if (client == null) {
            timer?.cancel();
            return null;
          }

          if (client.isActive) {
            Cache.client = client;
            emit(state.copyWith(client: client));
            timer?.cancel();
          }
        },
        forceFirst: true,
      );
    }

    final t = Timer.periodic(Duration(minutes: 3), checker);
    if (forceFirst) {
      checker(t);
    }
    userChecker = t.cancel;
  }

  Future<void> updateClient(Client client) async {
    await Future.wait([
      Server.auth.currentUser!.updateDisplayName(client.name),
      Server.auth.currentUser!.updatePhotoURL(client.photo),
    ]);

    Server.auth.currentUser!.reload();

    emit(state.copyWith(client: client));
    Cache.client = client;
  }

  Future<void> logOut() async {
    await Cache.clear(); // this will force the entire app to be clear!
    await Server.auth.signOut();

    emit(state.copyWith(client: null));
  }
}
