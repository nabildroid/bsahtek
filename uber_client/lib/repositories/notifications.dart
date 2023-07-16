import 'package:awesome_notifications/awesome_notifications.dart';

abstract class Notifications {
  static final AwesomeNotifications _instance = AwesomeNotifications();

  static Future<void> createChannels() async {
    await _instance.requestPermissionToSendNotifications();
    await _instance.initialize("resource://drawable/logo_circle_notification", [
      NotificationChannel(
        channelKey: "delivery",
        channelName: 'Following Delivery',
        channelDescription:
            'Notifications for client to follow their delivery status',
      )
    ]);
  }

  static Future<void> deliveryEnd() async {
    await _instance.createNotification(
      content: NotificationContent(
        id: 18,
        channelKey: 'delivery',
        criticalAlert: true,
        wakeUpScreen: true,
        showWhen: true,
        fullScreenIntent: true,
        notificationLayout: NotificationLayout.Default,
        displayOnForeground: true,
        displayOnBackground: true,
        title: 'Delivery ended',
        body: 'Your delivery has ended',
        payload: {
          "type": "delivery_end",
        },
      ),
    );
  }

  static Future<void> deliveryOnProgress(String productName) async {
    await _instance.createNotification(
      content: NotificationContent(
        id: 56,
        channelKey: 'delivery',
        locked: true,
        criticalAlert: true,
        wakeUpScreen: true,
        showWhen: true,
        fullScreenIntent: true,
        notificationLayout: NotificationLayout.Default,
        displayOnForeground: true,
        displayOnBackground: true,
        autoDismissible: false,
        title: 'Delivery on progress',
        body: 'Your delivery $productName is on progress',
        payload: {
          "type": "delivery",
          "deliveryName": productName,
        },
      ),
    );
  }

  static onClick(Function(String type) callback) {
    _instance.actionStream.listen((event) {
      if (event.payload?.containsKey("type") ?? false) {
        callback(event.payload!["type"].toString());
      }
    });
  }
}
