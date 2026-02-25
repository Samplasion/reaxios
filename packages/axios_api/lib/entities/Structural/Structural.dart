import 'package:axios_api/utils/utils.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:axios_api/utils/DateSerializer.dart';

part "Structural.g.dart";

@JsonSerializable()
class Structural extends Equatable {
  @JsonKey(name: "tipoVoti")
  final List<GradeKinds> gradeKinds;
  @JsonKey(name: "tipoAssenze")
  final List<SimpleKind> absenceKinds;
  @JsonKey(name: "tipoAutorizzazioni")
  final List<SimpleKind> authorizationKinds;
  @JsonKey(name: "tipoGiustificazione")
  final List<SimpleKind> justificationKinds;
  @JsonKey(name: "frazioniTemporali")
  final List<Periods> periods;

  final List absenceReasons;

  const Structural({
    required this.gradeKinds,
    required this.absenceKinds,
    required this.authorizationKinds,
    required this.justificationKinds,
    required this.periods,
    this.absenceReasons = const [],
  });

  factory Structural.fromJson(Map<String, dynamic> json) =>
      _$StructuralFromJson(json);

  Map<String, dynamic> toJson() => _$StructuralToJson(this);

  @override
  List<Object?> get props => [
        gradeKinds,
        absenceKinds,
        authorizationKinds,
        justificationKinds,
        periods,
      ];
}

@JsonSerializable()
class GradeKinds extends Equatable {
  @JsonKey(name: "idPlesso")
  final String schoolID;

  @JsonKey(name: "tipi")
  final List<GradeKind> kinds;

  const GradeKinds({required this.schoolID, required this.kinds});

  factory GradeKinds.fromJson(Map<String, dynamic> json) =>
      _$GradeKindsFromJson(json);

  Map<String, dynamic> toJson() => _$GradeKindsToJson(this);

  @override
  List<Object?> get props => [schoolID, kinds];
}

@JsonSerializable()
class GradeKind extends Equatable {
  @JsonKey(name: "tipo")
  final String kind;
  @JsonKey(name: "codice")
  final String code;
  @JsonKey(name: "desc")
  final String desc;

  const GradeKind({required this.kind, required this.code, required this.desc});

  factory GradeKind.fromJson(Map<String, dynamic> json) =>
      _$GradeKindFromJson(json);

  Map<String, dynamic> toJson() => _$GradeKindToJson(this);

  @override
  List<Object?> get props => [kind, code, desc];
}

@JsonSerializable()
class SimpleKind extends Equatable {
  @JsonKey(name: "tipo")
  final String kind;
  @JsonKey(name: "desc")
  final String desc;

  const SimpleKind({required this.kind, required this.desc});

  static SimpleKind empty() {
    return const SimpleKind(kind: "", desc: "");
  }

  factory SimpleKind.fromJson(Map<String, dynamic> json) =>
      _$SimpleKindFromJson(json);

  Map<String, dynamic> toJson() => _$SimpleKindToJson(this);

  @override
  List<Object?> get props => [kind, desc];
}

@JsonSerializable()
class Period extends Equatable {
  @JsonKey(name: "idFrazione", defaultValue: "", disallowNullValue: true)
  final String id;
  @JsonKey(name: "descFrazione", defaultValue: "")
  final String desc;
  @JsonKey(name: "dataInizio")
  @DateSerializer()
  final DateTime startDate;
  @JsonKey(name: "dataFine")
  @DateSerializer()
  final DateTime endDate;

  const Period({
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

  @override
  List<Object?> get props => [id, desc, startDate, endDate];
}

@JsonSerializable()
class Periods extends Equatable {
  @JsonKey(name: "idPlesso")
  final String schoolID;

  @JsonKey(name: "frazioni")
  final List<Period> periods;

  const Periods({required this.schoolID, required this.periods});

  factory Periods.fromJson(Map<String, dynamic> json) =>
      _$PeriodsFromJson(json);

  Map<String, dynamic> toJson() => _$PeriodsToJson(this);

  Period? getCurrentPeriod([DateTime? date]) {
    date ??= DateTime.now();
    return periods.firstWhereOrNull((p) => p.isCurrent(date));
  }

  @override
  List<Object?> get props => [schoolID, periods];
}
