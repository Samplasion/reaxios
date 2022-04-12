// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Structural.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Structural _$StructuralFromJson(Map<String, dynamic> json) => Structural(
      gradeKinds: (json['tipoVoti'] as List<dynamic>)
          .map((e) => GradeKinds.fromJson(e as Map<String, dynamic>))
          .toList(),
      absenceKinds: (json['tipoAssenze'] as List<dynamic>)
          .map((e) => SimpleKind.fromJson(e as Map<String, dynamic>))
          .toList(),
      authorizationKinds: (json['tipoAutorizzazioni'] as List<dynamic>)
          .map((e) => SimpleKind.fromJson(e as Map<String, dynamic>))
          .toList(),
      justificationKinds: (json['tipoGiustificazione'] as List<dynamic>)
          .map((e) => SimpleKind.fromJson(e as Map<String, dynamic>))
          .toList(),
      periods: (json['frazioniTemporali'] as List<dynamic>)
          .map((e) => Periods.fromJson(e as Map<String, dynamic>))
          .toList(),
      absenceReasons: json['absenceReasons'] as List<dynamic>? ?? const [],
    );

Map<String, dynamic> _$StructuralToJson(Structural instance) =>
    <String, dynamic>{
      'tipoVoti': instance.gradeKinds,
      'tipoAssenze': instance.absenceKinds,
      'tipoAutorizzazioni': instance.authorizationKinds,
      'tipoGiustificazione': instance.justificationKinds,
      'frazioniTemporali': instance.periods,
      'absenceReasons': instance.absenceReasons,
    };

GradeKinds _$GradeKindsFromJson(Map<String, dynamic> json) => GradeKinds(
      schoolID: json['idPlesso'] as String,
      kinds: (json['tipi'] as List<dynamic>)
          .map((e) => GradeKind.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$GradeKindsToJson(GradeKinds instance) =>
    <String, dynamic>{
      'idPlesso': instance.schoolID,
      'tipi': instance.kinds,
    };

GradeKind _$GradeKindFromJson(Map<String, dynamic> json) => GradeKind(
      kind: json['tipo'] as String,
      code: json['codice'] as String,
      desc: json['desc'] as String,
    );

Map<String, dynamic> _$GradeKindToJson(GradeKind instance) => <String, dynamic>{
      'tipo': instance.kind,
      'codice': instance.code,
      'desc': instance.desc,
    };

SimpleKind _$SimpleKindFromJson(Map<String, dynamic> json) => SimpleKind(
      kind: json['tipo'] as String,
      desc: json['desc'] as String,
    );

Map<String, dynamic> _$SimpleKindToJson(SimpleKind instance) =>
    <String, dynamic>{
      'tipo': instance.kind,
      'desc': instance.desc,
    };

Period _$PeriodFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    disallowNullValues: const ['idFrazione'],
  );
  return Period(
    id: json['idFrazione'] as String? ?? '',
    desc: json['descFrazione'] as String? ?? '',
    startDate: const DateSerializer().fromJson(json['dataInizio'] as String),
    endDate: const DateSerializer().fromJson(json['dataFine'] as String),
  );
}

Map<String, dynamic> _$PeriodToJson(Period instance) => <String, dynamic>{
      'idFrazione': instance.id,
      'descFrazione': instance.desc,
      'dataInizio': const DateSerializer().toJson(instance.startDate),
      'dataFine': const DateSerializer().toJson(instance.endDate),
    };

Periods _$PeriodsFromJson(Map<String, dynamic> json) => Periods(
      schoolID: json['idPlesso'] as String,
      periods: (json['frazioni'] as List<dynamic>)
          .map((e) => Period.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$PeriodsToJson(Periods instance) => <String, dynamic>{
      'idPlesso': instance.schoolID,
      'frazioni': instance.periods,
    };
