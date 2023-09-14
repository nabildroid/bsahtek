import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../model/seller.dart';
import '../repository/cache.dart';
import '../repository/messages_remote.dart';
import '../repository/server.dart';
import 'home_cubit.dart';

class AppState extends Equatable {
  Seller? seller;

  AppState({
    this.seller,
  });

  AppState copyWith({
    Seller? seller,
  }) {
    return AppState(
      seller: seller ?? this.seller,
    );
  }

  @override
  List<Object?> get props => [
        seller?.id,
      ];
}

class AppCubit extends Cubit<AppState> {
  AppCubit() : super(AppState());

  Future<void> setUser(Seller user) async {
    emit(state.copyWith(seller: user));
    Cache.seller = user;
    await deliveryManExists(user);
  }

  void removeUser() {
    Cache.seller = null;
  }

  Future<void> deliveryManExists(Seller seller) async {
    if (!Cache.isFirstRun) return;
    final userID = seller.id;
    final fcmToken = await RemoteMessages().getToken();

    await Server().assignNotiIDtoSeller(notiID: fcmToken, sellerID: userID);
  }

  Future<void> updateSeller(Seller seller) async {
    await Future.wait([
      Server.auth.currentUser!.updateDisplayName(seller.name),
      Server.auth.currentUser!.updatePhotoURL(seller.photo),
    ]);

    Server.auth.currentUser!.reload();

    emit(state.copyWith(seller: seller));
    Cache.seller = seller;
  }

  Future<void> logOut(BuildContext context) async {
    Cache.clear(); // this will force the entire app to be clear!

    try {
      await Future.wait([
        context.read<HomeCubit>().close(),
      ]);
    } catch (e) {}

    await Server.auth.signOut();

    emit(state.copyWith(seller: null));
  }
}
