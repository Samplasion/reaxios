// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Grade.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Grade _$GradeFromJson(Map<String, dynamic> json) {
  return Grade(
    id: json['idVoto'] as String,
    subjectID: json['idMat'] as String,
    subject: json['descMat'] as String,
    date: const DateSerializer().fromJson(json['data'] as String),
    kind: json['tipo'] as String,
    prettyGrade: json['voto'] as String,
    grade: const DoubleSerializer().fromJson(json['votoValore'] as String),
    weight: const DoubleSerializer().fromJson(json['peso'] as String),
    comment: json['commento'] as String,
    teacher: json['docente'] as String,
    seen: const BooleanSerializer().fromJson(json['vistato'] as String),
    seenBy: json['vistatoUtente'] as String?,
    seenOn: const DateSerializer().fromJson(json['vistatoData'] as String),
  )..period = json['period'] as String;
}

Map<String, dynamic> _$GradeToJson(Grade instance) => <String, dynamic>{
      'idVoto': instance.id,
      'idMat': instance.subjectID,
      'descMat': instance.subject,
      'data': const DateSerializer().toJson(instance.date),
      'tipo': instance.kind,
      'voto': instance.prettyGrade,
      'votoValore': const DoubleSerializer().toJson(instance.grade),
      'peso': const DoubleSerializer().toJson(instance.weight),
      'commento': instance.comment,
      'docente': instance.teacher,
      'vistato': const BooleanSerializer().toJson(instance.seen),
      'vistatoUtente': instance.seenBy,
      'vistatoData': const DateSerializer().toJson(instance.seenOn),
      'period': instance.period,
    };

APIGrades _$APIGradesFromJson(Map<String, dynamic> json) {
  return APIGrades(
    idAlunno: json['idAlunno'] as String,
    idFrazione: json['idFrazione'] as String,
    voti: (json['voti'] as List<dynamic>)
        .map((e) => Grade.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

Map<String, dynamic> _$APIGradesToJson(APIGrades instance) => <String, dynamic>{
      'idAlunno': instance.idAlunno,
      'idFrazione': instance.idFrazione,
      'voti': instance.voti,
    };
