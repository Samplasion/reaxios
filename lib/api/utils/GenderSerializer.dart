import 'package:json_annotation/json_annotation.dart';
import 'package:reaxios/api/enums/Gender.dart';

class GenderSerializer implements JsonConverter<Gender, String> {
  const GenderSerializer();

  @override
  Gender fromJson(String json) => json == "M" ? Gender.Male : Gender.Female;

  @override
  String toJson(Gender gender) => gender == Gender.Male ? "M" : "F";
}
