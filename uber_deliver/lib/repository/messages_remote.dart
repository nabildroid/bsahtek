import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:uber_deliver/repository/background.dart';

class RemoteMessages {
  final _firebaseMessages = FirebaseMessaging.instance;

  Future<void> initMessages() async {
    await _firebaseMessages.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: true,
    );
  }

  Future<String> getToken() async {
    final fCMToken = await _firebaseMessages.getToken();
    if (fCMToken == null) {
      throw Exception('Permission not granted');
    }

    return fCMToken;
  }

  void listenToNewToken(void Function(String) onNewToken) {
    _firebaseMessages.onTokenRefresh.listen((event) {
      onNewToken(event);
      print('New token: $event');
    });
  }

  void listenToMessages(
      Future<void> Function(RemoteMessage, bool fromForground) onMessage) {
    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      onMessage(event, false);
      print('Message opened app: ${event.data}');
    });
    FirebaseMessaging.onMessage.listen((event) {
      onMessage(event, true);
      print('Message received: ${event.data}');
    });
  }

  void setUpBackgroundMessageHandler() {
    FirebaseMessaging.onBackgroundMessage(
        Backgrounds.firebaseMessagingBackgroundHandler);
  }

  Future<void> attachToCell(String cellID) async {
    await _firebaseMessages.subscribeToTopic(cellID);
  }

  Future<void> unattachFromCells(List<String> cellsID) async {
    for (final cellID in cellsID) {
      await _firebaseMessages.unsubscribeFromTopic(cellID);
    }
  }
}
