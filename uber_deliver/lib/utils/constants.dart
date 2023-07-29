import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uber_client/cubits/bags_cubit.dart';

abstract class Constants {
  static const lastUpdateBeforeExpired = Duration(hours: 2);
  static const needAcceptanceBeforeExpired = Duration(minutes: 10);
  static const needDeliverBeforeExpired = Duration(minutes: 10);
  static const needSelfPickupBeforeExpired = Duration(hours: 1);
}
