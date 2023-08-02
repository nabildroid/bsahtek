import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:bsahtak/repositories/backgrounds.dart';

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

  Future<String?> getToken() async {
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

    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        onMessage(message);
        print('Message received: ${message.data}');
      }
    });
    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      onMessage(event);
      print('Message received: ${event.data}');
    });
  }

  void listenToNewToken(void Function(String) onNewToken) {
    _firebaseMessages.onTokenRefresh.listen((event) {
      onNewToken(event);
      print('New token: $event');
    });
  }

  void setUpBackgroundMessageHandler() {
    FirebaseMessaging.onBackgroundMessage(
      Backgrounds.firebaseMessagingBackgroundHandler,
    );
  }
}
