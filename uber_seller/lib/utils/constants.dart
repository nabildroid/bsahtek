abstract class Constants {
  // todo you can move those values to the server
  static const lastUpdateBeforeExpired = Duration(hours: 2);
  static const needAcceptanceBeforeExpired = Duration(minutes: 10);
  static const needDeliverBeforeExpired = Duration(minutes: 10);
  static const needSelfPickupBeforeExpired = Duration(hours: 1);
}
