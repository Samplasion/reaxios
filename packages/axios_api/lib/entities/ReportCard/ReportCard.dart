import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:axios_api/enums/ReportCardSubjectKind.dart';
import 'package:axios_api/utils/BooleanSerializer.dart';
import 'package:axios_api/utils/DateSerializer.dart';
import 'package:axios_api/utils/IntSerializer.dart';

part "ReportCard.g.dart";

@JsonSerializable()
class ReportCard extends Equatable {
  @JsonKey(name: "idAlunno")
  final String studentUUID;
  @JsonKey(name: "idFrazione")
  final String periodUUID;
  @JsonKey(name: "codiceFrazione")
  final String periodCode;
  @JsonKey(name: "descFrazione")
  final String period;
  @JsonKey(name: "esito")
  final String result;
  @JsonKey(name: "giudizio")
  final String rating;
  @JsonKey(name: "URL")
  final String url;
  @JsonKey(name: "letta")
  @BooleanSerializer()
  final bool read;
  @JsonKey(name: "visibile")
  @BooleanSerializer()
  final bool visible;
  @JsonKey(name: "materie")
  final List<ReportCardSubject> subjects;
  @JsonKey(name: "dataVisualizzazione")
  final String dateReadRaw;
  @JsonKey(includeFromJson: false, includeToJson: false)
  DateTime? get dateRead {
    try {
      final date = DateSerializer().fromJson(dateReadRaw);
      // The serializer returns the epoch as a sentinel
      // value if the server-returned date is invalid
      if (date.millisecondsSinceEpoch == 0) return null;
      return date;
    } catch (_) {
      return null;
    }
  }

  @JsonKey(name: "flagAssenzeVisibili")
  @BooleanSerializer()
  final bool canViewAbsences;
  @JsonKey(name: "ordineScuola", defaultValue: "")
  final String eduGrade;
  @JsonKey(name: "tipoPagella", defaultValue: "")
  final String cardKind;

  const ReportCard({
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
    required this.dateReadRaw,
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
        dateReadRaw: "****",
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
        dateReadRaw: "****",
        canViewAbsences: true,
        eduGrade: "",
        cardKind: "",
      );

  @override
  List<Object?> get props => [
        studentUUID,
        periodUUID,
        periodCode,
        period,
        result,
        rating,
        url,
        read,
        visible,
        subjects,
        dateRead,
        canViewAbsences,
        eduGrade,
        cardKind,
      ];
}

@JsonSerializable()
class ReportCardSubject extends Equatable {
  @JsonKey(name: "idMat")
  final String id;
  @JsonKey(name: "descMat", defaultValue: "")
  final String name;
  @JsonKey(name: "tipoMat")
  @ReportCardSubjectKindSerializer()
  final ReportCardSubjectKind kind;
  @JsonKey(name: "tipoRecupero")
  final String recoveryKind;
  @JsonKey(name: "assenze", defaultValue: "0")
  final String absences;
  @JsonKey(name: "mediaVoti", defaultValue: 0)
  final double gradeAverage;
  @JsonKey(name: "detail")
  final List<ReportCardSubjectDetail> details;

  num get parsedAbsences => num.tryParse(absences) ?? 0;

  const ReportCardSubject({
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

  @override
  List<Object?> get props => [
        id,
        name,
        kind,
        recoveryKind,
        absences,
        gradeAverage,
        details,
      ];
}

@JsonSerializable()
class ReportCardSubjectDetail extends Equatable {
  @JsonKey(name: "tipo")
  final String kind;
  final String label;
  @JsonKey(name: "voto")
  final String textGrade;
  @JsonKey(name: "votoValore")
  @IntSerializer()
  final int grade;

  const ReportCardSubjectDetail({
    required this.kind,
    required this.label,
    required this.textGrade,
    required this.grade,
  });

  factory ReportCardSubjectDetail.fromJson(Map<String, dynamic> json) =>
      _$ReportCardSubjectDetailFromJson(json);

  Map<String, dynamic> toJson() => _$ReportCardSubjectDetailToJson(this);

  @override
  List<Object?> get props => [
        kind,
        label,
        textGrade,
        grade,
      ];
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
