// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Absence.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Absence _$AbsenceFromJson(Map<String, dynamic> json) => Absence(
      id: json['id'] as String,
      date: const DateSerializer().fromJson(json['data'] as String),
      rawReason: json['motivo'] as String,
      kind: json['kind'] as String,
      kindJustified: json['kindJustified'] as String,
      concurs: const BooleanSerializer().fromJson(json['calcolo'] as String),
      hasTime: const BooleanSerializer().fromJson(json['ora'] as String),
      isJustifiable:
          const BooleanSerializer().fromJson(json['giustificabile'] as String),
      rawDateJustified: json['datagiust'] as String,
      rawKind: json['tipo'] as String,
      rawKindJustified: json['tipogiust'] as String,
      lessonHour: json['oralez'] == null
          ? 0
          : const IntSerializer().fromJson(json['oralez'] as String),
    );

Map<String, dynamic> _$AbsenceToJson(Absence instance) => <String, dynamic>{
      'id': instance.id,
      'data': const DateSerializer().toJson(instance.date),
      'kind': instance.kind,
      'tipo': instance.rawKind,
      'datagiust': instance.rawDateJustified,
      'kindJustified': instance.kindJustified,
      'tipogiust': instance.rawKindJustified,
      'motivo': instance.rawReason,
      'calcolo': const BooleanSerializer().toJson(instance.concurs),
      'ora': const BooleanSerializer().toJson(instance.hasTime),
      'oralez': const IntSerializer().toJson(instance.lessonHour),
      'giustificabile':
          const BooleanSerializer().toJson(instance.isJustifiable),
    };

APIAbsences _$APIAbsencesFromJson(Map<String, dynamic> json) => APIAbsences(
      idAlunno: json['idAlunno'] as String,
      idFrazione: json['idFrazione'] as String,
      descFrazione: json['descFrazione'] as String,
      assenze: (json['assenze'] as List<dynamic>)
          .map((e) => Absence.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$APIAbsencesToJson(APIAbsences instance) =>
    <String, dynamic>{
      'idAlunno': instance.idAlunno,
      'idFrazione': instance.idFrazione,
      'descFrazione': instance.descFrazione,
      'assenze': instance.assenze,
    };
