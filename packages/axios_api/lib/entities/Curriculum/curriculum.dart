import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../interfaces/AbstractJson.dart';

part 'curriculum.g.dart';

enum CurriculumOutcome {
  admitted,
  heldBack,
  suspended,
  noData,
}

List<Curriculum> curriculaFromJSON(List<dynamic> data) {
  List<dynamic> json = data.first;
  String studentID = data.last;
  return json
      .map((e) => APICurriculumData.fromJson(e))
      .firstWhere((element) => element.idAlunno == studentID)
      .curriculum;
}

@JsonSerializable()
class Curriculum extends Equatable implements AbstractJson {
  @JsonKey(name: "idPlesso")
  final String mechanisticCode;
  @JsonKey(name: "annoScolastico")
  final String schoolYear;
  @JsonKey(name: "descScuola")
  final String school;
  @JsonKey(name: "descCorso")
  final String course;
  @JsonKey(name: "sezione")
  final String section;
  @JsonKey(name: "classe")
  final int classYear;
  @JsonKey(name: "descEsito")
  final String? outcome;
  @JsonKey(name: "tipoEsito")
  final String outcomeTypeRaw;
  @JsonKey(includeFromJson: false)
  CurriculumOutcome get outcomeType {
    switch (outcomeTypeRaw) {
      case "-2":
        return CurriculumOutcome.suspended;
      case "0":
      case "":
        return CurriculumOutcome.noData;
      default:
        return int.parse(outcomeTypeRaw) < 0
            ? CurriculumOutcome.heldBack
            : CurriculumOutcome.admitted;
    }
  }

  @JsonKey(name: "credito")
  final String credits;

  const Curriculum({
    required this.mechanisticCode,
    required this.schoolYear,
    required this.school,
    required this.course,
    required this.section,
    required this.classYear,
    required this.outcome,
    required this.outcomeTypeRaw,
    required this.credits,
  });

  Map<String, dynamic> toJson() => _$CurriculumToJson(this);
  factory Curriculum.fromJson(Map<String, dynamic> json) =>
      _$CurriculumFromJson(json);

  @override
  List<Object?> get props => [
        mechanisticCode,
        schoolYear,
        school,
        course,
        section,
        classYear,
        outcome,
        outcomeType,
        credits,
      ];

  @override
  bool? get stringify => true;
}

@JsonSerializable()
class APICurriculumData extends Equatable implements AbstractJson {
  final String idAlunno;
  final List<Curriculum> curriculum;

  const APICurriculumData({
    required this.idAlunno,
    required this.curriculum,
  });

  Map<String, dynamic> toJson() => _$APICurriculumDataToJson(this);
  factory APICurriculumData.fromJson(Map<String, dynamic> json) =>
      _$APICurriculumDataFromJson(json);

  @override
  List<Object?> get props => [idAlunno, curriculum];
}
