import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:bsahtak/cubits/bags_cubit.dart';

abstract class Constants {
  static const defaultArea = Area(
    center: const LatLng(
      36.777609783186975,
      2.9853606820318834,
    ),
    name: "Beni Messous",
    radius: 30,
  );

  // todo you can move those values to the server
  static const lastUpdateBeforeExpired = Duration(hours: 2);
  static const needAcceptanceBeforeExpired = Duration(minutes: 10);
  static const needDeliverBeforeExpired = Duration(minutes: 10);
  static const needSelfPickupBeforeExpired = Duration(hours: 1);

  static const pauseReservingAfterReservation = Duration(minutes: 3);
}
