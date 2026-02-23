// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'curriculum.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Curriculum _$CurriculumFromJson(Map<String, dynamic> json) => Curriculum(
      mechanisticCode: json['idPlesso'] as String,
      schoolYear: json['annoScolastico'] as String,
      school: json['descScuola'] as String,
      course: json['descCorso'] as String,
      section: json['sezione'] as String,
      classYear: (json['classe'] as num).toInt(),
      outcome: json['descEsito'] as String?,
      outcomeTypeRaw: json['tipoEsito'] as String,
      credits: json['credito'] as String,
    );

Map<String, dynamic> _$CurriculumToJson(Curriculum instance) =>
    <String, dynamic>{
      'idPlesso': instance.mechanisticCode,
      'annoScolastico': instance.schoolYear,
      'descScuola': instance.school,
      'descCorso': instance.course,
      'sezione': instance.section,
      'classe': instance.classYear,
      'descEsito': instance.outcome,
      'tipoEsito': instance.outcomeTypeRaw,
      'credito': instance.credits,
    };

APICurriculumData _$APICurriculumDataFromJson(Map<String, dynamic> json) =>
    APICurriculumData(
      idAlunno: json['idAlunno'] as String,
      curriculum: (json['curriculum'] as List<dynamic>)
          .map((e) => Curriculum.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$APICurriculumDataToJson(APICurriculumData instance) =>
    <String, dynamic>{
      'idAlunno': instance.idAlunno,
      'curriculum': instance.curriculum,
    };
