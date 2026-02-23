import 'package:flutter_local_notifications/flutter_local_notifications.dart';

Future<void> sendNotification(
  String title,
  String body, {
  required int id,
  required String payload,
  required String androidIcon,
  required Function(String?) notificationPayload,
  AndroidNotificationDetails? androidDetails,
}) async {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings(androidIcon);
  final DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings(
    onDidReceiveLocalNotification: (_, __, ___, ____) {},
  );
  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
    macOS: initializationSettingsIOS,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (res) => notificationPayload(res.payload),
  );

  final NotificationDetails platformChannelSpecifics = NotificationDetails(
    android: androidDetails,
  );

  await flutterLocalNotificationsPlugin.show(
    id,
    title,
    body,
    platformChannelSpecifics,
    payload: payload,
  );
}
