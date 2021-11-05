import 'package:json_annotation/json_annotation.dart';
import 'package:reaxios/api/utils/DateSerializer.dart';

part "Structural.g.dart";

@JsonSerializable()
class Structural {
  @JsonKey(name: "tipoVoti")
  List<GradeKinds> gradeKinds;
  @JsonKey(name: "tipoAssenze")
  List<SimpleKind> absenceKinds;
  @JsonKey(name: "tipoAutorizzazioni")
  List<SimpleKind> authorizationKinds;
  @JsonKey(name: "tipoGiustificazione")
  List<SimpleKind> justificationKinds;
  @JsonKey(name: "frazioniTemporali")
  List<Periods> periods;

  List absenceReasons = [];

  Structural({
    required this.gradeKinds,
    required this.absenceKinds,
    required this.authorizationKinds,
    required this.justificationKinds,
    required this.periods,
  });

  factory Structural.fromJson(Map<String, dynamic> json) =>
      _$StructuralFromJson(json);

  Map<String, dynamic> toJson() => _$StructuralToJson(this);
}

@JsonSerializable()
class GradeKinds {
  @JsonKey(name: "idPlesso")
  String schoolID;

  @JsonKey(name: "tipi")
  List<GradeKind> kinds;

  GradeKinds({required this.schoolID, required this.kinds});

  factory GradeKinds.fromJson(Map<String, dynamic> json) =>
      _$GradeKindsFromJson(json);

  Map<String, dynamic> toJson() => _$GradeKindsToJson(this);
}

@JsonSerializable()
class GradeKind {
  @JsonKey(name: "tipo")
  String kind;
  @JsonKey(name: "codice")
  String code;
  @JsonKey(name: "desc")
  String desc;

  GradeKind({required this.kind, required this.code, required this.desc});

  factory GradeKind.fromJson(Map<String, dynamic> json) =>
      _$GradeKindFromJson(json);

  Map<String, dynamic> toJson() => _$GradeKindToJson(this);
}

@JsonSerializable()
class SimpleKind {
  @JsonKey(name: "tipo")
  String kind;
  @JsonKey(name: "desc")
  String desc;

  SimpleKind({required this.kind, required this.desc});

  static SimpleKind empty() {
    return SimpleKind(kind: "", desc: "");
  }

  factory SimpleKind.fromJson(Map<String, dynamic> json) =>
      _$SimpleKindFromJson(json);

  Map<String, dynamic> toJson() => _$SimpleKindToJson(this);
}

@JsonSerializable()
class Period {
  @JsonKey(name: "idFrazione", defaultValue: "", disallowNullValue: true)
  String id;
  @JsonKey(name: "descFrazione", defaultValue: "")
  String desc;
  @JsonKey(name: "dataInizio")
  @DateSerializer()
  DateTime startDate;
  @JsonKey(name: "dataFine")
  @DateSerializer()
  DateTime endDate;

  Period({
    required this.id,
    required this.desc,
    required this.startDate,
    required this.endDate,
  });

  factory Period.fromJson(Map<String, dynamic> json) => _$PeriodFromJson(json);

  Map<String, dynamic> toJson() => _$PeriodToJson(this);

  bool isCurrent([DateTime? date]) {
    date ??= DateTime.now();
    return date.isAfter(startDate) && date.isBefore(endDate);
  }

  static Period empty() {
    return Period(
      id: "",
      desc: "",
      startDate: DateTime.now(),
      endDate: DateTime.now(),
    );
  }
}

@JsonSerializable()
class Periods {
  @JsonKey(name: "idPlesso")
  String schoolID;

  @JsonKey(name: "frazioni")
  List<Period> periods;

  Periods({required this.schoolID, required this.periods});

  factory Periods.fromJson(Map<String, dynamic> json) =>
      _$PeriodsFromJson(json);

  Map<String, dynamic> toJson() => _$PeriodsToJson(this);

  Period? getCurrentPeriod([DateTime? date]) {
    date ??= DateTime.now();
    // ignore: unnecessary_cast
    return (periods as List<Period?>)
        .firstWhere((p) => p?.isCurrent(date) ?? false, orElse: () => null);
  }
}
