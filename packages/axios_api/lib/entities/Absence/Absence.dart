import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:axios_api/client.dart';
import 'package:axios_api/entities/Structural/Structural.dart';
import 'package:axios_api/interfaces/AbstractJson.dart';
import 'package:axios_api/utils/BooleanSerializer.dart';
import 'package:axios_api/utils/DateSerializer.dart';
import 'package:axios_api/utils/IntSerializer.dart';
import 'package:axios_api/utils/utils.dart';

part 'Absence.g.dart';

@JsonSerializable()
class Absence extends Equatable implements AbstractJson {
  // num id;
  String id;

  @JsonKey(name: "data")
  @DateSerializer()
  DateTime date;

  String kind = "";

  @JsonKey(name: "tipo")
  String rawKind;

  @JsonKey(name: "datagiust")
  String rawDateJustified;
  bool get isJustified => rawDateJustified.isNotEmpty;
  DateTime get dateJustified => const DateSerializer().fromJson(rawDateJustified);

  String kindJustified = "";

  @JsonKey(name: "tipogiust")
  String rawKindJustified;

  @JsonKey(name: "motivo")
  String rawReason;
  String get reason => rawReason == "< non visibile >" ? "" : rawReason;

  @JsonKey(name: "calcolo")
  @BooleanSerializer()
  bool concurs;

  @JsonKey(name: "ora")
  @BooleanSerializer()
  bool hasTime;

  @JsonKey(name: "oralez")
  @IntSerializer()
  int lessonHour;

  @JsonKey(name: "giustificabile")
  @BooleanSerializer()
  bool isJustifiable;

  @JsonKey(ignore: true)
  late Axios session;

  @JsonKey(ignore: true)
  String period;

  Absence({
    required this.id,
    required this.date,
    required this.rawReason,
    required this.kind,
    required this.kindJustified,
    required this.concurs,
    required this.hasTime,
    required this.isJustifiable,
    required this.rawDateJustified,
    required this.rawKind,
    required this.rawKindJustified,
    this.lessonHour = 0,
    this.period = "",
  });

  static empty() {
    return Absence(
      rawReason: "",
      id: "",
      date: DateTime.now(),
      kind: "",
      kindJustified: "",
      concurs: false,
      hasTime: false,
      isJustifiable: false,
      rawDateJustified: "",
      lessonHour: 0,
      rawKind: "",
      rawKindJustified: "",
      period: "",
    );
  }

  factory Absence.fromJson(Map<String, dynamic> json) =>
      _$AbsenceFromJson(json);

  Absence setSession(Axios session) {
    this.session = session;
    return this;
  }

  Absence setPeriod(String period) {
    this.period = period;
    return this;
  }

  Absence setKinds(Structural structural) {
    kind = structural.absenceKinds
        .firstWhere((element) => element.kind == rawKind,
            orElse: () => SimpleKind.empty())
        .desc;
    kindJustified = structural.justificationKinds
        .firstWhere((element) => element.kind == rawKindJustified,
            orElse: () => SimpleKind.empty())
        .desc;
    return this;
  }

  Map<String, dynamic> toJson() => _$AbsenceToJson(this);

  Future<bool> justify() async {
    return await session.justifyAbsence(this);
  }

  @override
  String toString() {
    return "Absence{id: $id, date: $date, kind: $kind, rawKind: $rawKind, rawDateJustified: $rawDateJustified, rawReason: $rawReason, concurs: $concurs, hasTime: $hasTime, lessonHour: $lessonHour, isJustifiable: $isJustifiable, rawKindJustified: $rawKindJustified, period: $period}";
  }

  static test() {
    return Absence(
      rawReason: "Assenza docente",
      id: "3",
      date: DateTime.now(),
      kind: "C",
      kindJustified: "D",
      concurs: false,
      hasTime: false,
      isJustifiable: true,
      rawDateJustified: dateToString(DateTime.now(), short: true),
      lessonHour: 3,
      rawKind: "C",
      rawKindJustified: "D",
      period: "I QUADRIMESTRE",
    );
  }

  @override
  List<Object?> get props => [
        id,
        date,
        rawReason,
        kind,
        kindJustified,
        concurs,
        hasTime,
        isJustifiable,
        rawDateJustified,
        lessonHour,
        rawKind,
        rawKindJustified,
        period,
      ];
}

@JsonSerializable()
class APIAbsences extends Equatable {
  String idAlunno;
  String idFrazione;
  String descFrazione;
  List<Absence> assenze;

  APIAbsences({
    required this.idAlunno,
    required this.idFrazione,
    required this.descFrazione,
    required this.assenze,
  });

  factory APIAbsences.fromJson(Map<String, dynamic> json) =>
      _$APIAbsencesFromJson(json);

  Map<String, dynamic> toJson() => _$APIAbsencesToJson(this);

  @override
  List<Object?> get props => [
        idAlunno,
        idFrazione,
        descFrazione,
        assenze,
      ];
}
