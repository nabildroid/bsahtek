import 'package:firebase_messaging/firebase_messaging.dart';

class RemoteMessages {
  final _firebaseMessages = FirebaseMessaging.instance;

  Future<String> initMessages() async {
    await _firebaseMessages.requestPermission();

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
}
