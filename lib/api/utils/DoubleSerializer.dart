import 'package:json_annotation/json_annotation.dart';

class DoubleSerializer implements JsonConverter<double, String> {
  const DoubleSerializer();

  @override
  double fromJson(String? json) => json == null
      ? double.negativeInfinity
      : double.parse(json.replaceAll(",", "."));

  @override
  String toJson(double num) => num.toString();
}
