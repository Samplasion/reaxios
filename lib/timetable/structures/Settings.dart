import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:reaxios/api/utils/ColorSerializer.dart';
import 'package:reaxios/enums/AverageMode.dart';
import 'package:reaxios/enums/GradeDisplay.dart';
import 'package:reaxios/structs/SubjectObjective.dart';
import 'package:reaxios/structs/calendar_event.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../enums/UpdateNagMode.dart';
import '../download.dart' if (dart.library.html) '../download_web.dart';
import 'Event.dart';
import '../utils.dart';

// part 'Settings.g.dart';

// class Settings = _Settings with _$Settings;

class UndisposableChangeNotifier with ChangeNotifier {
  bool _disposed = false;

  @override
  void notifyListeners() {
    if (!_disposed) {
      super.notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void undispose() {
    _disposed = false;
  }
}

class Settings extends UndisposableChangeNotifier {
  late SharedPreferences _prefs;

  init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  SharedPreferences get prefs => _prefs;

  setEvents(List<Event> events) {
    _prefs.setString(
      "events",
      jsonEncode(events.map((e) => e.toJson()).toList()),
    );
    notifyListeners();
  }

  List<Event> getEvents() {
    return (jsonDecode(_prefs.getString("events") ?? "[]") as List<dynamic>)
        .map((e) => Event.fromJson(e))
        .toList();
  }

  setIgnoreList(String source) {
    _prefs.setStringList("ignoreList", source.split(" "));
    notifyListeners();
  }

  List<String> getIgnoreList() {
    return _prefs.getStringList("ignoreList") ??
        [
          "e",
          "dell",
          "del",
          "di",
          "delle",
          "della",
        ];
  }

  setLessonDuration(Duration lessonDuration) {
    lessonDuration.inMinutes;
    _prefs.setInt("lessonDuration", lessonDuration.inMinutes);
    notifyListeners();
  }

  Duration getLessonDuration() {
    return Duration(minutes: _prefs.getInt("lessonDuration") ?? 60);
  }

  setEnabledDays(List<int> days) {
    _prefs.setString("enabledDays", jsonEncode(days));
    notifyListeners();
  }

  List<int> getEnabledDays() {
    // return [1, 2, 3, 4, 5];
    return (jsonDecode(_prefs.getString("enabledDays") ?? "[1, 2, 3, 4, 5]")
            as List<dynamic>)
        .map((e) => e as int)
        .toList();
  }

  int getWeeks() {
    return _prefs.getInt("weeks") ?? 1;
  }

  setWeeks(int weeks) {
    _prefs.setInt("weeks", weeks);
    notifyListeners();
  }

  DateTime getFirstWeekDate() {
    final savedDate = DateTime.fromMillisecondsSinceEpoch(
      _prefs.getInt("firstWeekDate") ?? DateTime.now().millisecondsSinceEpoch,
    );
    return DateTimeUtils.getFirstDayOfWeek(savedDate);
  }

  setFirstWeekDate(DateTime date) {
    final firstDayOfWeek = DateTimeUtils.getFirstDayOfWeek(date);
    _prefs.setInt("firstWeekDate", firstDayOfWeek.millisecondsSinceEpoch);
    notifyListeners();
  }

  String getThemeMode() {
    return _prefs.getString("themeMode") ?? "dynamic";
  }

  setThemeMode(String themeMode) {
    _prefs.setString("themeMode", themeMode);
    notifyListeners();
  }

  GradeDisplay getGradeDisplay() {
    return deserializeGradeDisplay(
        _prefs.getString("grade-display") ?? GradeDisplay.decimal.serialized);
  }

  void setGradeDisplay(GradeDisplay gradeDisplay) {
    _prefs.setString("grade-display", gradeDisplay.serialized);
    notifyListeners();
  }

  Color getPrimaryColor() {
    if (_prefs.getString("primary-color") == null) {
      return Colors.orange[400]!;
    }
    return ColorSerializer().fromJson(_prefs.getString("primary-color")!);
  }

  setPrimaryColor(Color color) {
    _prefs.setString("primary-color", ColorSerializer().toJson(color));
    notifyListeners();
  }

  Color getAccentColor() {
    if (_prefs.getString("accent-color") == null) {
      return Colors.purple[400]!;
    }
    return ColorSerializer().fromJson(_prefs.getString("accent-color")!);
  }

  setAccentColor(Color color) {
    _prefs.setString("accent-color", ColorSerializer().toJson(color));
    notifyListeners();
  }

  AverageMode getAverageMode() {
    return deserializeAverageMode(_prefs.getString("averageMode") ??
        AverageMode.allGradesAverage.serialized);
  }

  void setAverageMode(AverageMode averageMode) {
    _prefs.setString("averageMode", averageMode.serialized);
    notifyListeners();
  }

  Map<String, SubjectObjective> getSubjectObjectives() {
    final objectives = _prefs.getString("subjectObjectives") ?? "{}";
    return (jsonDecode(objectives) as Map<String, dynamic>)
        .map((key, value) => MapEntry(key, SubjectObjective.fromJson(value)));
  }

  void setSubjectObjectives(Map<String, SubjectObjective> objectives) {
    _prefs.setString("subjectObjectives", jsonEncode(objectives));
    notifyListeners();
  }

  UpdateNagMode getUpdateNagMode() {
    return deserializeUpdateNagMode(
        _prefs.getString("updateNagMode") ?? UpdateNagMode.alert.serialized);
  }

  void setUpdateNagMode(UpdateNagMode updateNagMode) {
    _prefs.setString("updateNagMode", updateNagMode.serialized);
    notifyListeners();
  }

  List<CustomCalendarEvent> getCalendarEvents() {
    final events = _prefs.getString("calendarEvents") ?? "[]";
    return (jsonDecode(events) as List<dynamic>)
        .map((e) => CustomCalendarEvent.fromJson(e))
        .toList();
  }

  void setCalendarEvents(List<CustomCalendarEvent> events) {
    _prefs.setString(
      "calendarEvents",
      jsonEncode(events.map((e) => e.toJson()).toList()),
    );
    notifyListeners();
  }

  bool getUseDynamicColor() {
    return _prefs.getBool("useDynamicColor") ?? false;
  }

  void setUseDynamicColor(bool useDynamicColor) {
    _prefs.setBool("useDynamicColor", useDynamicColor);
    notifyListeners();
  }

  bool getHarmonizeColors() {
    return _prefs.getBool("harmonizeColors") ?? true;
  }

  void setHarmonizeColors(bool harmonizeColors) {
    _prefs.setBool("harmonizeColors", harmonizeColors);
    notifyListeners();
  }

  bool getUseGradients() {
    return _prefs.getBool("useGradients") ?? false;
  }

  void setUseGradients(bool useGradients) {
    _prefs.setBool("useGradients", useGradients);
    notifyListeners();
  }

  // --------

  Future<String> get directory async {
    // Directory tempDir = await getApplicationDocumentsDirectory();
    late Directory tempDir;
    if (isPhone()) {
      tempDir = await getTemporaryDirectory();
    } else {
      tempDir = (await getApplicationDocumentsDirectory());
    }
    return tempDir.path;
  }

  Future<String> getRandomFilePath({
    String name = "settings",
    String extension = "json",
  }) async {
    if (isPhone()) {
      return "${await directory}/${name}_${getRandomString(20)}.$extension";
    }
    return "${await directory}/$name.$extension";
  }

  bool isPhone() {
    return Platform.isAndroid || Platform.isIOS;
  }

  Future share([List<String>? keys, String name = "settings.json"]) async {
    final encoded = jsonEncode(
      Map<String, dynamic>.fromIterable(
        json.entries
            .where((element) => keys == null || keys.contains(element.key)),
        key: (e) => e.key,
        value: (entry) => entry.value,
      ),
    );

    if (!kIsWeb) {
      if (!isPhone()) {
        String? path = await FilePicker.platform.saveFile(
          type: FileType.custom,
          allowedExtensions: ["json"],
          fileName: name,
        );
        if (path == null) return;
        final file = File(path);
        await file.writeAsString(encoded, flush: true);
      } else {
        final filePath = await getRandomFilePath();
        final file = File(filePath);
        await file.writeAsString(encoded, flush: true);

        await Share.shareFiles([filePath]);
      }
    } else {
      download("settings.json", encoded.codeUnits);
    }

    // await file.delete();
  }

  Future load() async {
    FilePickerResult? res = await FilePicker.platform.pickFiles(
      dialogTitle: "Select the Settings file.",
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (res == null) return;

    String jsonString;
    if (kIsWeb) {
      if (res.files.first.bytes == null) return;
      jsonString = utf8.decode(res.files.first.bytes!.toList());
    } else {
      File file = File(res.files.first.path!);
      jsonString = await file.readAsString();
    }
    Map<String, dynamic> parsed = jsonDecode(jsonString);

    json = parsed;
  }

  Map<String, dynamic> get json => {
        "events": jsonDecode(_prefs.getString("events") ?? "[]"),
        "ignoreList": _prefs.getStringList("ignoreList"),
        "lessonDuration": _prefs.getInt("lessonDuration"),
        "enabledDays": getEnabledDays(),
        "weeks": getWeeks(),
        "firstWeekDate": getFirstWeekDate().millisecondsSinceEpoch,
        "themeMode": getThemeMode(),
        "grade-display": getGradeDisplay().serialized,
        "primary-color": getPrimaryColor().value,
        "accent-color": getAccentColor().value,
        "averageMode": getAverageMode().serialized,
        "subjectObjectives": getSubjectObjectives()
            .map((key, value) => MapEntry(key, value.toJson())),
        "updateNagMode": getUpdateNagMode().serialized,
        "calendarEvents": getCalendarEvents().map((e) => e.toJson()).toList(),
        "useDynamicColor": getUseDynamicColor(),
        "harmonizeColors": getHarmonizeColors(),
        "useGradients": getUseGradients(),
      };

  set json(Map<String, dynamic> obj) {
    if (obj.containsKey("events") && obj["events"] is List) {
      final events =
          (obj["events"] as List).map((l) => Event.fromJson(l)).toList();
      print(events);
      if (events.every(((e) => e.isValid))) {
        setEvents(
          events,
        );
      } else {
        throw Exception("Invalid events");
      }
    }
    if (obj.containsKey("ignoreList") && obj["ignoreList"] is String) {
      setIgnoreList(obj["ignoreList"] as String);
    }
    if (obj.containsKey("lessonDuration") && obj["lessonDuration"] is int) {
      setLessonDuration(Duration(minutes: obj["lessonDuration"] as int));
    }
    if (obj.containsKey("enabledDays") && obj["enabledDays"] is List) {
      setEnabledDays(
          (obj["enabledDays"] as List).map((d) => d as int).toList());
    }
    if (obj.containsKey("weeks") && obj["weeks"] is int) {
      setWeeks(obj["weeks"] as int);
    }
    if (obj.containsKey("firstWeekDate") && obj["firstWeekDate"] is int) {
      setFirstWeekDate(DateTime.fromMillisecondsSinceEpoch(
        obj["firstWeekDate"] as int,
      ));
    }
    if (obj.containsKey("themeMode") && obj["themeMode"] is String) {
      setThemeMode(obj["themeMode"] as String);
    }
    if (obj.containsKey("grade-display") && obj["grade-display"] is String) {
      setGradeDisplay(
        deserializeGradeDisplay(obj["grade-display"] as String),
      );
    }
    if (obj.containsKey("primary-color") && obj["primary-color"] is int) {
      setPrimaryColor(Color(obj["primary-color"] as int));
    }
    if (obj.containsKey("accent-color") && obj["accent-color"] is int) {
      setAccentColor(Color(obj["accent-color"] as int));
    }
    if (obj.containsKey("averageMode") && obj["averageMode"] is String) {
      setAverageMode(
        deserializeAverageMode(obj["averageMode"] as String),
      );
    }
    if (obj.containsKey("subjectObjectives") &&
        obj["subjectObjectives"] is Map) {
      setSubjectObjectives(
        (obj["subjectObjectives"] as Map).map((key, value) {
          return MapEntry(
            key,
            SubjectObjective.fromJson(value as Map<String, dynamic>),
          );
        }),
      );
    }
    if (obj.containsKey("updateNagMode") && obj["updateNagMode"] is String) {
      setUpdateNagMode(
        deserializeUpdateNagMode(obj["updateNagMode"] as String),
      );
    }
    if (obj.containsKey("calendarEvents") && obj["calendarEvents"] is List) {
      setCalendarEvents(
        (obj["calendarEvents"] as List)
            .map((e) => CustomCalendarEvent.fromJson(e))
            .toList(),
      );
    }
    if (obj.containsKey("useDynamicColor") && obj["useDynamicColor"] is bool) {
      setUseDynamicColor(obj["useDynamicColor"] as bool);
    }
    if (obj.containsKey("harmonizeColors") && obj["harmonizeColors"] is bool) {
      setHarmonizeColors(obj["harmonizeColors"] as bool);
    }
    if (obj.containsKey("useGradients") && obj["useGradients"] is bool) {
      setUseGradients(obj["useGradients"] as bool);
    }

    notifyListeners();
  }

  weekForDate(DateTime dateTime) {
    final firstDayOfWeek = getFirstWeekDate();
    final week = (dateTime.difference(firstDayOfWeek).inDays / 7).floor();
    final maxWeeks = getWeeks();
    return (week % maxWeeks) + 1;
  }
}
