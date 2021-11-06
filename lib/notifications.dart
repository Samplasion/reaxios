import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';
import 'dart:ui';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart' as S;
import 'package:reaxios/api/Axios.dart';
import 'package:reaxios/api/entities/Account.dart';
import 'package:reaxios/api/entities/Grade/Grade.dart';
import 'package:reaxios/api/entities/Login/Login.dart';
import 'package:reaxios/api/utils/Encrypter.dart';
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

bool listened = false;

/// The native notification plugin.
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void gradesBackgroundService() async {
  final DateTime now = DateTime.now();
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

  if (!listened) {
    listened = true;
    port.listen((message) async {
      if (message is Map) {
        if (message['action'] == 'kill' && message['isolateId'] == isolateId) {
          print(
              '[Background] [${DateTime.now()}] Background isolate #$isolateId killed from UI. Reason: ${message['message']}');
          current.kill(priority: Isolate.immediate);
          return;
        }
        if (message['event'] == 'loginData' && message['action'] == 'login') {
          final Map<String, String> loginData = message['data'];
          final String school = loginData['school']!;
          final String user = loginData['user']!;
          final String pass = loginData['pass']!;

          if (school.isEmpty || user.isEmpty || pass.isEmpty) {
            print(
                '[Background] [${DateTime.now()}] Background isolate #$isolateId killed. Reason: No login.');
            current.kill(priority: Isolate.immediate);
            return;
          }

          Axios session = new Axios(
              new AxiosAccount(school, user, Encrypter.decrypt(pass)));
          late Login login;
          try {
            login = await session.login();
          } catch (e) {
            debugPrint(e.toString());
            print(
                '[Background] [${DateTime.now()}] Background isolate #$isolateId killed. Reason: Login failed.');
            current.kill(priority: Isolate.immediate);
            return;
          }

          List<Grade> grades = await session.getGrades();

          uiSendPort.send({
            'event': 'grades',
            'isolateId': isolateId,
            'time': now.millisecondsSinceEpoch,
            'action': 'grades',
            'grades':
                grades.where((g) => !g.seen).map((g) => g.toJson()).toList(),
          });
        }
      }
    });
  }

  uiSendPort.send({
    'event': 'isolateStarted',
    'isolateId': isolateId,
    'time': now.millisecondsSinceEpoch,
    'port': port.sendPort,
    'action': 'getLoginData',
  });
}

Future<void> respondToBackgroundIsolate(
  int isolateId,
  String action,
  SendPort sendPort,
  Map message,
) async {
  print(
      '[UI] [${DateTime.now()}] Background isolate #$isolateId sent message: $message');

  switch (action) {
    case 'getLoginData':
      final prefs = await SharedPreferences.getInstance();

      if (!prefs.containsKey("school") ||
          !prefs.containsKey("user") ||
          !prefs.containsKey("pass")) {
        print('No login.');
        sendPort.send({
          'event': 'loginData',
          'isolateId': isolateId,
          'action': 'kill',
          'message': "The user hasn't logged in yet.",
        });
      } else {
        final school = prefs.getString("school");
        final user = prefs.getString("user");
        final pass = prefs.getString("pass");

        print('[UI] [${DateTime.now()}] Login data: $school, $user, $pass');

        sendPort.send({
          'event': 'loginData',
          'isolateId': isolateId,
          'action': 'login',
          'data': {
            'school': school,
            'user': user,
            'pass': pass,
          }
        });
      }

      break;

    case 'grades':
      final List<Map<String, dynamic>> gradesJSON = message['grades'];
      final List<Grade> grades =
          gradesJSON.map((g) => Grade.fromJson(g)).toList();

      // Grades is already filtered to the unread grades.
      // Show a notification for each grade.
      for (final grade in grades) {
        final AndroidNotificationDetails androidPlatformChannelSpecifics =
            AndroidNotificationDetails(
          'newGrades',
          'Nuovi voti',
          channelDescription: 'Notifiche riguardo a nuovi voti',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          ticker: 'Nuovo voto in ${grade.subject}',
        );
        final NotificationDetails platformChannelSpecifics =
            NotificationDetails(
          android: androidPlatformChannelSpecifics,
        );
        await flutterLocalNotificationsPlugin.show(
          int.tryParse(grade.id) ?? 0,
          "Nuovo voto",
          '${grade.subject}: ${grade.prettyGrade}',
          platformChannelSpecifics,
          payload: 'grade:${grade.id}',
        );
      }

      break;
    default:
      print('[UI] [${DateTime.now()}] Unknown action: $action');
  }
}

Tuple2<Duration, Function> getBackgroundService(int id) {
  switch (id) {
    case BackgroundServiceID.grades:
      return Tuple2(Duration(minutes: 15), gradesBackgroundService);
  }

  throw "Unreachable";
}

Future<void> initializeNotifications(
    Function(String?) notificationPayload) async {
  if (!Platform.isAndroid) return;

  bool result = await AndroidAlarmManager.initialize();

  if (!result) {
    print("!!! FAILED INITIALIZING ANDROID NOTIFICATIONS !!!");
  }

  print("[UI] [${DateTime.now()}] Notifications initialized.");

  await _initializeCrossPlatformNotificationsPlugin(notificationPayload);
}

Future<void> _initializeCrossPlatformNotificationsPlugin(
    Function(String?) notificationPayload) async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('ic_grade_new');
  final IOSInitializationSettings initializationSettingsIOS =
      IOSInitializationSettings(
    onDidReceiveLocalNotification: (_, __, ___, ____) {},
  );
  final MacOSInitializationSettings initializationSettingsMacOS =
      MacOSInitializationSettings();
  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
    macOS: initializationSettingsMacOS,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onSelectNotification: notificationPayload,
  );
}

Future<void> startNotificationsService() async {
  if (!Platform.isAndroid) return;

  // Register the UI isolate's SendPort to allow for communication from the
  // background isolate.
  IsolateNameServer.registerPortWithName(
    port.sendPort,
    isolateName,
  );

  port.listen((message) {
    if (message is Map) {
      int isolateId = message['isolateId'];
      SendPort sendPort = message['port'];
      String action = message['action'];

      print(
          "[UI] [${DateTime.now()}] Received message from UI isolate: $message");
      respondToBackgroundIsolate(isolateId, action, sendPort, message);
    }
  });

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
      exact: true,
    );
  }
}

Future<void> cancelScheduledServices() async {
  for (int id in BackgroundServiceID.values) {
    await AndroidAlarmManager.cancel(id);
  }
}
