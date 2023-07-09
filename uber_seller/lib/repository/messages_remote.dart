import 'package:firebase_messaging/firebase_messaging.dart';

import '../main.dart';

class RemoteMessages {
  final _firebaseMessages = FirebaseMessaging.instance;

  Future<String> initMessages() async {
    await _firebaseMessages.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: true,
    );

    final fCMToken = await _firebaseMessages.getToken();
    if (fCMToken == null) {
      throw Exception('Permission not granted');
    }

    return fCMToken;
  }

  void listenToMessages(void Function(RemoteMessage) onMessage) {
    FirebaseMessaging.onMessage.listen((event) {
      onMessage(event);
      print('Message received: ${event.data}');
    });
  }

  void setUpBackgroundMessageHandler() {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  void listenToNewToken(void Function(String) onNewToken) {
    _firebaseMessages.onTokenRefresh.listen((event) {
      onNewToken(event);
      print('New token: $event');
    });
  }
}
