import 'package:json_annotation/json_annotation.dart';
import 'package:axios_api/interfaces/AbstractJson.dart';

part 'School.g.dart';

@JsonSerializable()
class School implements AbstractJson {
  @JsonKey(name: "fsIntitolazione")
  String title;
  @JsonKey(name: "fsNome")
  String name;
  @JsonKey(name: "fsCF")
  String id;
  @JsonKey(name: "fsCap")
  String zipCode;
  @JsonKey(name: "fsRegione")
  String region;
  @JsonKey(name: "fsCitta")
  String city;
  @JsonKey(name: "fsProvincia")
  String province;

  School(
      {required this.id,
      required this.title,
      required this.name,
      required this.zipCode,
      required this.region,
      required this.city,
      required this.province});

  factory School.fromJson(Map<String, dynamic> json) => _$SchoolFromJson(json);

  Map<String, dynamic> toJson() => _$SchoolToJson(this);
}
