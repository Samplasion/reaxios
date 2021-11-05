import 'package:json_annotation/json_annotation.dart';

class IntSerializer implements JsonConverter<int, String> {
  const IntSerializer();

  @override
  int fromJson(String? json) => json == null
      ? -9999999999999
      : int.parse((json == "" ? 0 : json).toString().split("-")[0]);

  @override
  String toJson(int num) => num.toString();
}
