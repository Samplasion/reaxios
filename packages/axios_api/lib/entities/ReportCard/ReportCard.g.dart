// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ReportCard.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReportCard _$ReportCardFromJson(Map<String, dynamic> json) => ReportCard(
      studentUUID: json['idAlunno'] as String,
      periodUUID: json['idFrazione'] as String,
      periodCode: json['codiceFrazione'] as String,
      period: json['descFrazione'] as String,
      result: json['esito'] as String,
      rating: json['giudizio'] as String,
      url: json['URL'] as String,
      read: const BooleanSerializer().fromJson(json['letta'] as String),
      visible: const BooleanSerializer().fromJson(json['visibile'] as String),
      subjects: (json['materie'] as List<dynamic>)
          .map((e) => ReportCardSubject.fromJson(e as Map<String, dynamic>))
          .toList(),
      dateReadRaw: json['dataVisualizzazione'] as String,
      canViewAbsences: json['flagAssenzeVisibili'] == null
          ? true
          : const BooleanSerializer()
              .fromJson(json['flagAssenzeVisibili'] as String),
      eduGrade: json['ordineScuola'] as String? ?? '',
      cardKind: json['tipoPagella'] as String? ?? '',
    );

Map<String, dynamic> _$ReportCardToJson(ReportCard instance) =>
    <String, dynamic>{
      'idAlunno': instance.studentUUID,
      'idFrazione': instance.periodUUID,
      'codiceFrazione': instance.periodCode,
      'descFrazione': instance.period,
      'esito': instance.result,
      'giudizio': instance.rating,
      'URL': instance.url,
      'letta': const BooleanSerializer().toJson(instance.read),
      'visibile': const BooleanSerializer().toJson(instance.visible),
      'materie': instance.subjects,
      'dataVisualizzazione': instance.dateReadRaw,
      'flagAssenzeVisibili':
          const BooleanSerializer().toJson(instance.canViewAbsences),
      'ordineScuola': instance.eduGrade,
      'tipoPagella': instance.cardKind,
    };

ReportCardSubject _$ReportCardSubjectFromJson(Map<String, dynamic> json) =>
    ReportCardSubject(
      id: json['idMat'] as String,
      name: json['descMat'] as String? ?? '',
      kind: const ReportCardSubjectKindSerializer()
          .fromJson(json['tipoMat'] as String),
      recoveryKind: json['tipoRecupero'] as String,
      absences: json['assenze'] as String? ?? '0',
      gradeAverage: (json['mediaVoti'] as num?)?.toDouble() ?? 0,
      details: (json['detail'] as List<dynamic>)
          .map((e) =>
              ReportCardSubjectDetail.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ReportCardSubjectToJson(ReportCardSubject instance) =>
    <String, dynamic>{
      'idMat': instance.id,
      'descMat': instance.name,
      'tipoMat': const ReportCardSubjectKindSerializer().toJson(instance.kind),
      'tipoRecupero': instance.recoveryKind,
      'assenze': instance.absences,
      'mediaVoti': instance.gradeAverage,
      'detail': instance.details,
    };

ReportCardSubjectDetail _$ReportCardSubjectDetailFromJson(
        Map<String, dynamic> json) =>
    ReportCardSubjectDetail(
      kind: json['tipo'] as String,
      label: json['label'] as String,
      textGrade: json['voto'] as String,
      grade: const IntSerializer().fromJson(json['votoValore'] as String),
    );

Map<String, dynamic> _$ReportCardSubjectDetailToJson(
        ReportCardSubjectDetail instance) =>
    <String, dynamic>{
      'tipo': instance.kind,
      'label': instance.label,
      'voto': instance.textGrade,
      'votoValore': const IntSerializer().toJson(instance.grade),
    };
