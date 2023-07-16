import 'package:awesome_notifications/awesome_notifications.dart';

abstract class Notifications {
  static final AwesomeNotifications _instance = AwesomeNotifications();

  static Future<void> notAvailable() async {
    await _instance.cancelNotificationsByChannelKey("requests");
    await _instance.cancelNotificationsByChannelKey("running");
    await _instance.cancelNotificationsByChannelKey("availablity");
  }

  static Future<void> onMission({
    required String city,
    required String clientName,
    required double distance,
    required Duration duration,
  }) async {
    await notAvailable();

    await _instance.createNotification(
      content: NotificationContent(
        id: 10,
        channelKey: "running",
        title: "On Mission",
        fullScreenIntent: true,
        body: "You are delivering to $clientName",
        notificationLayout: NotificationLayout.Default,
        wakeUpScreen: true,
        displayOnForeground: true,
        displayOnBackground: true,
        showWhen: true,
        autoDismissible: false,
        criticalAlert: true,
        locked: true,
        ticker: "$city",
        payload: {
          "type": "onMission",
        },
      ),
    );
  }

  static Future<void> available({
    required String city,
  }) async {
    await notAvailable();

    await _instance.createNotification(
      content: NotificationContent(
        id: 1,
        channelKey: "availablity",
        title: "Available in $city",
        fullScreenIntent: true,
        body: "You are now available to deliver orders in $city and around",
        notificationLayout: NotificationLayout.Default,
        wakeUpScreen: true,
        displayOnForeground: true,
        displayOnBackground: true,
        showWhen: true,
        autoDismissible: false,
        criticalAlert: true,
        locked: true,
        ticker: "$city",
        payload: {
          "type": "available",
        },
      ),
    );
  }

  static Future<void> closeToStore({
    required String storeName,
  }) async {
    await _instance.createNotification(
        content: NotificationContent(
      id: 2,
      channelKey: "running",
      title: "Close to Store",
      body: "You are almost arrived to $storeName",
      notificationLayout: NotificationLayout.Default,
      displayOnForeground: true,
      displayOnBackground: true,
      showWhen: true,
      payload: {
        "type": "closeToStore",
      },
    ));
  }

  static Future<void> closeToClient({
    required String clientName,
    required String clientPhone,
  }) async {
    await _instance.createNotification(
        content: NotificationContent(
          id: 3,
          channelKey: "running",
          title: "Close to ${clientName}",
          body: "You are almost arrived to $clientName location",
          notificationLayout: NotificationLayout.Default,
          displayOnForeground: true,
          displayOnBackground: true,
          locked: true,
          showWhen: true,
          payload: {
            "type": "closeToStore",
          },
        ),
        actionButtons: [
          NotificationActionButton(
            key: "CALL",
            label: "Call",
            enabled: true,
            icon: "resource://drawable/res_ic_phone_call",
          ),
        ]);
  }

  static Future<void> createChannels() async {
    // _instance.initialize(defaultIcon, channels)

    await _instance.setChannel(NotificationChannel(
      channelKey: "requests",
      channelName: 'Delivery Requests',
      channelDescription:
          'Notifications for when clients requests to have a delivery for thier orders',
    ));

    await _instance.setChannel(NotificationChannel(
      channelKey: "availablity",
      channelName: 'Availablity For Delivery',
      channelDescription:
          'Notifications for when you are available to deliver orders',
    ));

    await _instance.setChannel(NotificationChannel(
      channelKey: "running",
      channelName: 'Running Delivery',
      channelDescription: 'Notifications for when you are running a delivery',
    ));
  }

  static onClick(Function(String type) callback) {
    _instance.actionStream.listen((event) {
      if (event.payload?.containsKey("type") ?? false) {
        callback(event.payload!["type"].toString());
      }
    });
  }
}
