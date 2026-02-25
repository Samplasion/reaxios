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

    if (dateParts.length < 3) return DateTime.fromMillisecondsSinceEpoch(0);

    return DateTime(int.parse(dateParts[2]), int.parse(dateParts[1]),
        int.parse(dateParts[0]), hours, minutes, seconds);
  }

  @override
  DateTime fromJson(String json) => _axiosStringToDate(json);

  @override
  String toJson(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    final h = date.hour.toString().padLeft(2, '0');
    final min = date.minute.toString().padLeft(2, '0');
    final s = date.second.toString().padLeft(2, '0');
    return "$d/$m/$y $h:$min:$s";
  }
}
