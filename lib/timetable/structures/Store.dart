import 'package:flutter/foundation.dart';

import 'DayTime.dart';
import 'Weekday.dart';

class Store with ChangeNotifier, DiagnosticableTreeMixin {
  DayTime? _startingTime;
  DayTime? get startingTime => _startingTime;
  set startingTime(DayTime? dt) {
    _startingTime = dt;
    notifyListeners();
  }

  Weekday? _lastWeekday;
  Weekday? get lastWeekday => _lastWeekday;
  set lastWeekday(Weekday? wd) {
    _lastWeekday = wd;
    notifyListeners();
  }
}
