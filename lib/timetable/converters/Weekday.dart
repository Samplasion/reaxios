import 'package:json_annotation/json_annotation.dart';
import '../structures/Weekday.dart';

class WeekdayConverter extends JsonConverter<Weekday, int> {
  const WeekdayConverter();

  @override
  Weekday fromJson(int json) {
    if (json >= 1 && json <= 7) {
      return Weekday.get(json, 1);
    }
    int day = (json / 100).floor();
    int week = json - day * 100;
    return Weekday.get(day, week);
  }

  @override
  int toJson(Weekday object) {
    return object.value * 100 + object.week;
  }
}
