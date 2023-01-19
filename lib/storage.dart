import 'package:shared_preferences/shared_preferences.dart';

import 'timetable/structures/Settings.dart';

class Storage extends UndisposableChangeNotifier {
  late SharedPreferences _prefs;

  init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  String? getLastStudentID() {
    final v = _prefs.getString("selectedStudent");
    return v == "\$#null\$#" ? null : v;
  }

  void setLastStudentID(String? studentID) {
    _prefs.setString("selectedStudent", studentID ?? "\$#null\$#");
  }
}
