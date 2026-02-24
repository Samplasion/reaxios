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
      DarwinInitializationSettings();
  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
    macOS: initializationSettingsIOS,
  );

  await flutterLocalNotificationsPlugin.initialize(
    settings: initializationSettings,
    onDidReceiveNotificationResponse: (res) =>
        notificationPayload(res?.payload),
  );

  final NotificationDetails platformChannelSpecifics = NotificationDetails(
    android: androidDetails,
  );

  await flutterLocalNotificationsPlugin.show(
    id: id,
    title: title,
    body: body,
    notificationDetails: platformChannelSpecifics,
    payload: payload,
  );
}
