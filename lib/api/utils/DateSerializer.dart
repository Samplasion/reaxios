import 'package:json_annotation/json_annotation.dart';

class DateSerializer implements JsonConverter<DateTime, String> {
  const DateSerializer();

  DateTime _axiosStringToDate(String whole) {
    final dateString = whole.split(" ")[0];
    final timeString = whole.split(" ").length > 1 ? whole.split(" ")[1] : "";

    var dateParts = dateString.split("/");

    var hours = 0, minutes = 0, seconds = 0;

    if (timeString.trim() != "") {
      hours = int.parse(timeString.split(":")[0]);
      minutes = int.parse(timeString.split(":")[1]);
      seconds = int.parse(timeString.split(":")[2]);
    }

    if (dateParts.length < 3) return new DateTime.fromMillisecondsSinceEpoch(0);

    // month is 0-based, that's why we need dataParts[1] - 1
    return new DateTime(int.parse(dateParts[2]), int.parse(dateParts[1]),
        int.parse(dateParts[0]), hours, minutes, seconds);
  }

  @override
  DateTime fromJson(String json) => _axiosStringToDate(json);

  @override
  String toJson(DateTime color) => color.toIso8601String();
}
