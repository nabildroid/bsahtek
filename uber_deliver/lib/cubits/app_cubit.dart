import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:uber_deliver/repository/messages_remote.dart';

import '../models/delivery_man.dart';
import '../repository/server.dart';

class AppState extends Equatable {
  final DeliveryMan? deliveryMan;

  AppState({
    this.deliveryMan,
  });

  @override
  List<Object?> get props => [
        deliveryMan?.id,
      ];
}

class AppCubit extends Cubit<AppState> {
  AppCubit() : super(AppState());

  Future<void> init() async {
    const userID = "YUVjVIca2XHcryIT5KAF";
    final fcmToken = await RemoteMessages().initMessages();

    await Server().assignNotiIDtoDeliveryMan(userID, fcmToken);
  }
}
