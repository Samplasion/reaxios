import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:reaxios/api/Axios.dart';
import 'package:reaxios/api/entities/Account.dart';
import 'package:reaxios/api/entities/Grade/Grade.dart';
import 'package:reaxios/api/utils/Encrypter.dart';
import 'package:reaxios/notifications.dart';
import 'package:reaxios/tuple.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BackgroundServiceID {
  static const int grades = 67890;

  static get values => [grades];
}

/// The name associated with the UI isolate's [SendPort].
const String isolateName = 'isolate';

/// A port used to communicate from a background isolate to the UI isolate.
final ReceivePort port = ReceivePort();

void gradesBackgroundService() async {
  final Isolate current = Isolate.current;
  final int isolateId = current.hashCode;

  SendPort? uiSendPort = IsolateNameServer.lookupPortByName(isolateName);
  if (uiSendPort == null) {
    print(
        '[Background] [${DateTime.now()}] No UI isolate found. Shutting down background isolate.');
    current.kill(priority: Isolate.immediate);
    return;
  }

  print('[Background] [${DateTime.now()}] Background isolate #$isolateId ran.');

  // 1. Get the shared preferences.
  // 2. Get the account.
  // 3. Check if any of the strings is empty.
  // 4. Get the grades.
  // 5. Send the notification.

  final SharedPreferences prefs = await SharedPreferences.getInstance();

  final String school = prefs.getString('school') ?? '';
  final String user = prefs.getString('user') ?? '';
  final String pass = prefs.getString('pass') ?? '';

  if (school.isEmpty || user.isEmpty || pass.isEmpty) {
    print(
        '[Background] [${DateTime.now()}] [#$isolateId] Missing credentials.');
    current.kill(priority: Isolate.immediate);
    return;
  }

  Axios session =
      new Axios(new AxiosAccount(school, user, Encrypter.decrypt(pass)));
  try {
    await session.login();
  } catch (e) {
    debugPrint(e.toString());
    print(
        '[Background] [${DateTime.now()}] [#$isolateId] Background isolate killed. Reason: Login failed.');
    current.kill(priority: Isolate.immediate);
    return;
  }

  List<Grade> grades = await session.getGrades();

  for (final grade in grades.where((grade) => !grade.seen)) {
    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'newGrades',
      'Nuovi voti',
      channelDescription: 'Notifiche riguardo a nuovi voti',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      ticker: 'Nuovo voto in ${grade.subject}',
    );
    await sendNotification(
      "Nuovo voto",
      '${grade.subject}: ${grade.prettyGrade}',
      id: int.tryParse(grade.id) ?? 0,
      androidDetails: androidPlatformChannelSpecifics,
      payload: 'grade:${grade.id}',
      notificationPayload: print,
      androidIcon: 'ic_grade_new',
    );
  }

  uiSendPort.send({
    'event': 'isolateStarted',
    'isolateId': isolateId,
    'time': DateTime.now().millisecondsSinceEpoch,
    'port': port.sendPort,
    'action': 'getLoginData',
  });
}

Tuple2<Duration, Function> getBackgroundService(int id) {
  switch (id) {
    case BackgroundServiceID.grades:
      return Tuple2(Duration(minutes: 15), gradesBackgroundService);
  }

  throw "Unreachable";
}

Future<void> initializeNotifications(
    Function(String?) _notificationPayload) async {
  if (!Platform.isAndroid) return;

  bool result = await AndroidAlarmManager.initialize();

  if (!result) {
    print("!!! FAILED INITIALIZING ANDROID NOTIFICATIONS !!!");
  }

  print("[UI] [${DateTime.now()}] Notifications initialized.");
}

Future<void> startNotificationServices() async {
  if (!Platform.isAndroid) return;

  // Register the UI isolate's SendPort to allow for communication from the
  // background isolates.
  IsolateNameServer.registerPortWithName(
    port.sendPort,
    isolateName,
  );

  for (int id in BackgroundServiceID.values) {
    Tuple2<Duration, Function> tuple = getBackgroundService(id);
    print(
        "[UI] [${DateTime.now()}] Starting service with ID #$id. Next run in ${tuple.first}.");
    await AndroidAlarmManager.periodic(
      tuple.first,
      id,
      tuple.second,
      allowWhileIdle: true,
      rescheduleOnReboot: true,
    );
  }
}

Future<void> cancelScheduledServices() async {
  for (int id in BackgroundServiceID.values) {
    await AndroidAlarmManager.cancel(id);
  }
}
