import 'package:awesome_notifications/awesome_notifications.dart';

abstract class Notifications {
  static final AwesomeNotifications _instance = AwesomeNotifications();

  static Future<void> createChannels() async {
    // todo setup the default channel for firebase messaging
    await _instance.requestPermissionToSendNotifications();
    await _instance.initialize(null, [
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

  static Future<void> orderAccepted(bool isPickup) async {
    await _instance.createNotification(
      content: NotificationContent(
        id: 13,
        channelKey: 'delivery',
        criticalAlert: true,
        wakeUpScreen: true,
        showWhen: true,
        locked: isPickup,
        fullScreenIntent: true,
        notificationLayout: NotificationLayout.Default,
        displayOnForeground: true,
        displayOnBackground: true,
        title: 'Your order is Accepted',
        body: isPickup ? 'You can pick it up' : 'its on the way',
        payload: {
          "type": "orderAccepted",
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

  static Future<void> scheduleRating(String productName, String orderID) async {
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
        autoDismissible: true,
        title: 'rate $productName!',
        body: 'did you like $productName?',
        payload: {
          "type": "rate",
          "orderID": orderID,
          "bagName": productName,
        },
      ),
      schedule: NotificationCalendar(
        hour: 20,
        minute: 0,
        second: 0,
        weekday: DateTime.now().hour > 20
            ? DateTime.now().weekday + 1
            : DateTime.now().weekday,
        millisecond: 0,
        repeats: false,
      ),
    );
  }

  // clear
  static Future<void> clear() async {
    await _instance.cancelNotificationsByChannelKey("delivery");
  }

  static onClick(Function(String type, dynamic payload) callback) {
    _instance.actionStream.listen((event) {
      if (event.payload?.containsKey("type") ?? false) {
        callback(event.payload!["type"].toString(), event.payload!);
      }
    });
  }
}
