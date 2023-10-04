import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bsahtak/cubits/bags_cubit.dart';
import 'package:bsahtak/cubits/home_cubit.dart';
import 'package:bsahtak/models/ad.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:bsahtak/models/client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../repositories/cache.dart';
import '../repositories/messages_remote.dart';
import '../repositories/notifications.dart';
import '../repositories/server.dart';

class AppState extends Equatable {
  Client? client;

  List<Ad> ads;

  AppState({
    this.client,
    required this.ads,
  });

  AppState copyWith({
    Client? client,
    List<Ad>? ads,
  }) {
    return AppState(
      client: client ?? this.client,
      ads: ads ?? this.ads,
    );
  }

  @override
  List<Object?> get props => [client?.toJson(), ...ads.map((e) => e.id)];
}

class AppCubit extends Cubit<AppState> {
  AppCubit() : super(AppState(ads: []));

  Future<void> setUser(Client user) async {
    emit(state.copyWith(client: user));

    Server().getAds().then((ads) => emit(state.copyWith(
          ads: ads,
        )));

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
    if (!(await Cache.isFirstRun())) return;

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

  Future<void> logOut(BuildContext context) async {
    await Cache.clear(); // this will force the entire app to be clear!

    try {
      await Future.wait([
        context.read<BagsQubit>().close(),
        context.read<HomeCubit>().close(),
      ]);
    } catch (e) {}

    await Server.auth.signOut();

    emit(state.copyWith(client: null));
  }
}
