import 'package:json_annotation/json_annotation.dart';
import '../structures/DayTime.dart';

class TimeOfDayConverter extends JsonConverter<DayTime, int> {
  const TimeOfDayConverter();

  @override
  DayTime fromJson(int json) {
    final hour = (json / 100).truncate();
    final minute = (json - hour * 100).truncate();
    return DayTime(hour: hour, minute: minute);
  }

  @override
  int toJson(DayTime object) {
    return object.hour * 100 + object.minute;
  }
}
