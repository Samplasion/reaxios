import 'package:json_annotation/json_annotation.dart';
import 'package:reaxios/api/enums/ReportCardSubjectKind.dart';
import 'package:reaxios/api/utils/BooleanSerializer.dart';
import 'package:reaxios/api/utils/DateSerializer.dart';
import 'package:reaxios/api/utils/IntSerializer.dart';

part "ReportCard.g.dart";

@JsonSerializable()
class ReportCard {
  @JsonKey(name: "idAlunno")
  String studentUUID;
  @JsonKey(name: "idFrazione")
  String periodUUID;
  @JsonKey(name: "codiceFrazione")
  String periodCode;
  @JsonKey(name: "descFrazione")
  String period;
  @JsonKey(name: "esito")
  String result;
  @JsonKey(name: "giudizio")
  String rating;
  @JsonKey(name: "URL")
  String url;
  @JsonKey(name: "letta")
  @BooleanSerializer()
  bool read;
  @JsonKey(name: "visibile")
  @BooleanSerializer()
  bool visible;
  @JsonKey(name: "materie")
  List<ReportCardSubject> subjects;
  @JsonKey(name: "dataVisualizzazione")
  @DateSerializer()
  DateTime dateRead;
  @JsonKey(name: "flagAssenzeVisibili")
  @BooleanSerializer()
  bool canViewAbsences;
  @JsonKey(name: "ordineScuola", defaultValue: "")
  String eduGrade;
  @JsonKey(name: "tipoPagella", defaultValue: "")
  String cardKind;

  ReportCard({
    required this.studentUUID,
    required this.periodUUID,
    required this.periodCode,
    required this.period,
    required this.result,
    required this.rating,
    required this.url,
    required this.read,
    required this.visible,
    required this.subjects,
    required this.dateRead,
    required this.canViewAbsences,
    this.eduGrade = "",
    this.cardKind = "",
  });

  factory ReportCard.fromJson(Map<String, dynamic> json) =>
      _$ReportCardFromJson(json);

  Map<String, dynamic> toJson() => _$ReportCardToJson(this);

  static ReportCard empty() => ReportCard(
        studentUUID: "",
        periodUUID: "",
        periodCode: "",
        period: "",
        result: "",
        rating: "",
        url: "",
        read: false,
        visible: false,
        subjects: [],
        dateRead: DateTime.now(),
        canViewAbsences: false,
        eduGrade: "",
        cardKind: "",
      );

  static ReportCard test() => ReportCard(
        studentUUID: "9d8f8f9d-b8b8-4b8b-b8b8-b8b8b8b8b8b8",
        periodUUID: "9d8f8f9d-b8b8-4b8b-b8b8-b8b8b8b8b8b8",
        periodCode: "abcde",
        period: "I Quadrimestre",
        result: "Ammesso",
        rating: "Ottimo",
        url: "https://www.google.com",
        read: true,
        visible: true,
        subjects: [],
        dateRead: DateTime.now(),
        canViewAbsences: true,
        eduGrade: "",
        cardKind: "",
      );
}

@JsonSerializable()
class ReportCardSubject {
  @JsonKey(name: "idMat")
  String id;
  @JsonKey(name: "descMat", defaultValue: "")
  String name;
  @JsonKey(name: "tipoMat")
  @ReportCardSubjectKindSerializer()
  ReportCardSubjectKind kind;
  @JsonKey(name: "tipoRecupero")
  String recoveryKind;
  @JsonKey(name: "assenze", defaultValue: 0)
  double absences;
  @JsonKey(name: "mediaVoti", defaultValue: 0)
  double gradeAverage;
  @JsonKey(name: "detail")
  List<ReportCardSubjectDetail> details;

  ReportCardSubject({
    required this.id,
    required this.name,
    required this.kind,
    required this.recoveryKind,
    required this.absences,
    required this.gradeAverage,
    required this.details,
  });

  factory ReportCardSubject.fromJson(Map<String, dynamic> json) =>
      _$ReportCardSubjectFromJson(json);

  Map<String, dynamic> toJson() => _$ReportCardSubjectToJson(this);
}

@JsonSerializable()
class ReportCardSubjectDetail {
  @JsonKey(name: "tipo")
  String kind;
  String label;
  @JsonKey(name: "voto")
  String textGrade;
  @JsonKey(name: "votoValore")
  @IntSerializer()
  int grade;

  ReportCardSubjectDetail({
    required this.kind,
    required this.label,
    required this.textGrade,
    required this.grade,
  });

  factory ReportCardSubjectDetail.fromJson(Map<String, dynamic> json) =>
      _$ReportCardSubjectDetailFromJson(json);

  Map<String, dynamic> toJson() => _$ReportCardSubjectDetailToJson(this);
}

class ReportCardSubjectKindSerializer
    implements JsonConverter<ReportCardSubjectKind, String> {
  const ReportCardSubjectKindSerializer();

  @override
  ReportCardSubjectKind fromJson(String json) {
    switch ("$json".toLowerCase()) {
      case "1":
        return ReportCardSubjectKind.Religion;
      case "4":
        return ReportCardSubjectKind.Behavior;
      case "7":
        return ReportCardSubjectKind.AltSubject;
      case "0":
      default:
        return ReportCardSubjectKind.Other;
    }
  }

  @override
  String toJson(ReportCardSubjectKind b) {
    switch (b) {
      case ReportCardSubjectKind.Religion:
        return "1";
      case ReportCardSubjectKind.Behavior:
        return "4";
      case ReportCardSubjectKind.AltSubject:
        return "7";
      case ReportCardSubjectKind.Other:
        return "0";
    }
  }
}
