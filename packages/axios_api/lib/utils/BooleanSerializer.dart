import 'package:json_annotation/json_annotation.dart';

class BooleanSerializer implements JsonConverter<bool, String> {
  const BooleanSerializer();

  @override
  bool fromJson(String json) {
    switch (json.toLowerCase()) {
      case "s":
      case "si":
      case "true":
      case "1":
      case "on":
        return true;
      default:
        return false;
    }
  }

  @override
  String toJson(bool b) => b.toString();
}
