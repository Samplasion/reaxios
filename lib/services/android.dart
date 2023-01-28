import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart' as S;
import 'package:reaxios/api/utils/ColorSerializer.dart';
import 'package:reaxios/api/Axios.dart';
import 'package:reaxios/api/entities/Account.dart';
import 'package:reaxios/api/entities/Bulletin/Bulletin.dart';
import 'package:reaxios/api/entities/Grade/Grade.dart';
import 'package:reaxios/api/utils/Encrypter.dart';
import 'package:reaxios/notifications.dart';
import 'package:reaxios/services/compute.dart';
import 'package:reaxios/tuple.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/entities/Structural/Structural.dart';

final defaultPrimary = Colors.orange[400]!;
final defaultAccent = Colors.purple[400]!;

class BackgroundServiceID {
  static const int grades = 67890;
  static const int bulletins = 73264;

  static get values => [grades, bulletins];
}

/// The name associated with the UI isolate's [SendPort].
const String isolateName = 'isolate';

final cs = ColorSerializer();

/// A port used to communicate from a background isolate to the UI isolate.
final ReceivePort port = ReceivePort();

Future<Axios?> getSession(Isolate current) async {
  await S.Settings.init();

  final SharedPreferences prefs = await SharedPreferences.getInstance();

  final String school = prefs.getString('school') ?? '';
  final String user = prefs.getString('user') ?? '';
  final String pass = prefs.getString('pass') ?? '';

  if (school.isEmpty || user.isEmpty || pass.isEmpty) {
    print(
        '[Background] [${DateTime.now()}] [#${current.hashCode}] Missing credentials.');
    current.kill(priority: Isolate.immediate);
    return null;
  }

  Axios session = new Axios(
      new AxiosAccount(school, user, Encrypter.decrypt(pass)),
      compute: compute);
  try {
    await session.login();
    await session.getStudents();
    final userID = prefs.getString('selectedStudent');
    if (userID != null) session.setStudentByID(userID);
  } catch (e) {
    debugPrint(e.toString());
    print(
        '[Background] [${DateTime.now()}] [#${current.hashCode}] Background isolate killed. Reason: Login failed.');
    current.kill(priority: Isolate.immediate);
  }

  return session;
}

void gradesBackgroundService() async {
  final Isolate current = Isolate.current;
  final int isolateId = current.hashCode;

  SendPort? uiSendPort = IsolateNameServer.lookupPortByName(isolateName);
  if (uiSendPort == null) {
    print(
        '[Background] [${DateTime.now()}] [#$isolateId] [gradesBackgroundService] INFO: No UI isolate found.');
  }

  print(
      '[Background] [${DateTime.now()}] [#$isolateId] [gradesBackgroundService] Background isolate ran.');

  // 1. Get the shared preferences.
  // 2. Get the account.
  // 3. Check if any of the strings is empty.
  // 4. Get the grades.
  // 5. Send the notification.

  Axios? session = await getSession(current);
  if (session == null) {
    print(
        '[Background] [${DateTime.now()}] [#$isolateId] [gradesBackgroundService] FATAL: Background isolate killed. Reason: getSession() returned null.');
    return;
  }

  Structural structural = await session.getStructural();
  List<Grade> grades = await session.getGrades(structural);

  // TODO: add shown grades to shared preferences

  for (final grade in grades.where((grade) => !grade.seen)) {
    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'newGrades',
      'Nuovi voti',
      channelDescription: 'Notifiche riguardo a nuovi voti',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      ticker: 'Nuovo voto in ${grade.subject}',
      onlyAlertOnce: true,
      color: cs.fromJson(
        S.Settings.getValue("primary-color") ?? cs.toJson(defaultPrimary),
      ),
      styleInformation: BigTextStyleInformation(
        grade.comment,
        contentTitle: '${grade.subject}: ${grade.prettyGrade}',
      ),
      when: grade.date.millisecondsSinceEpoch,
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
}

void bulletinBoardBackgroundService() async {
  final Isolate current = Isolate.current;
  final int isolateId = current.hashCode;

  SendPort? uiSendPort = IsolateNameServer.lookupPortByName(isolateName);
  if (uiSendPort == null) {
    print(
        '[Background] [${DateTime.now()}] [#$isolateId] [bulletinBoardBackgroundService] INFO: No UI isolate found.');
  }

  print(
      '[Background] [${DateTime.now()}] [#$isolateId] [bulletinBoardBackgroundService] Background isolate ran.');

  Axios? session = await getSession(current);
  if (session == null) {
    print(
        '[Background] [${DateTime.now()}] [#$isolateId] [bulletinBoardBackgroundService] FATAL: Background isolate killed. Reason: getSession() returned null.');
    return;
  }

  List<Bulletin> bulletins = await session.getBulletins();

  for (final bulletin in bulletins.where((grade) => !grade.read)) {
    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'bulletinBoard',
      'Nuove comunicazioni',
      channelDescription: 'Notifiche per le comunicazioni dalla segreteria',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      ticker: 'Nuova comunicazione - ${bulletin.humanReadableKind}.',
      styleInformation: BigTextStyleInformation(
        bulletin.desc,
        contentTitle: bulletin.humanReadableKind,
      ),
      onlyAlertOnce: true,
      color: cs.fromJson(
        S.Settings.getValue("primary-color") ?? cs.toJson(defaultPrimary),
      ),
      showWhen: true,
      when: bulletin.date.millisecondsSinceEpoch,
    );
    await sendNotification(
      "Nuova comunicazione",
      bulletin.desc,
      // id: int.tryParse(grade.id) ?? 0,
      id: bulletin.id.hashCode,
      androidDetails: androidPlatformChannelSpecifics,
      // payload: 'grade:${grade.id}',
      payload: '',
      notificationPayload: print,
      androidIcon: 'ic_bulletin_new',
    );
  }
}

Tuple2<Duration, Function> getBackgroundService(int id) {
  switch (id) {
    case BackgroundServiceID.grades:
      return Tuple2(Duration(minutes: 15), gradesBackgroundService);
    case BackgroundServiceID.bulletins:
      return Tuple2(Duration(minutes: 15), bulletinBoardBackgroundService);
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
      startAt: DateTime.now().add(Duration(seconds: 10)),
    );
  }
}

Future<void> cancelScheduledServices() async {
  for (int id in BackgroundServiceID.values) {
    await AndroidAlarmManager.cancel(id);
  }
}
