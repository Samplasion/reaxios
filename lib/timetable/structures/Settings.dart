import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';
import 'package:path_provider/path_provider.dart';
import 'package:reaxios/api/utils/ColorSerializer.dart';
import 'package:reaxios/enums/GradeDisplay.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'Event.dart';
import '../utils.dart';

// part 'Settings.g.dart';

// class Settings = _Settings with _$Settings;

class Settings with ChangeNotifier {
  late SharedPreferences _prefs;

  init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  @override
  dispose() {
    throw UnimplementedError();
  }

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
    String extension = "json.txt",
  }) async {
    if (isPhone()) {
      return "${await directory}/${name}_${getRandomString(20)}.$extension";
    }
    return "${await directory}/$name.$extension";
  }

  bool isPhone() {
    return Platform.isAndroid || Platform.isIOS;
  }

  Future share() async {
    final filePath = await getRandomFilePath();

    final file = File(filePath);
    await file.writeAsString(jsonEncode(json), flush: true);

    await Share.shareFiles([filePath]);

    // await file.delete();
  }

  Future load() async {
    FilePickerResult? res = await FilePicker.platform.pickFiles(
      dialogTitle: "Select the Settings file.",
      type: FileType.custom,
      allowedExtensions: ['json', 'txt'],
    );
    if (res == null) return;

    File file = File(res.files.first.path!);
    String jsonString = await file.readAsString();
    Map<String, dynamic> parsed = jsonDecode(jsonString);

    json = parsed;
  }

  Map<String, dynamic> get json => {
        "events": jsonDecode(_prefs.getString("events")!),
        "ignoreList": _prefs.getStringList("ignoreList"),
        "lessonDuration": _prefs.getInt("lessonDuration"),
        "enabledDays": getEnabledDays(),
        "weeks": getWeeks(),
        "firstWeekDate": getFirstWeekDate().millisecondsSinceEpoch,
      };

  set json(Map<String, dynamic> obj) {
    if (obj.containsKey("events") && obj["events"] is List) {
      setEvents(
        (obj["events"] as List).map((l) => Event.fromJson(l)).toList(),
      );
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
    notifyListeners();
  }

  weekForDate(DateTime dateTime) {
    final firstDayOfWeek = getFirstWeekDate();
    final week = (dateTime.difference(firstDayOfWeek).inDays / 7).floor();
    final maxWeeks = getWeeks();
    return (week % maxWeeks) + 1;
  }
}
