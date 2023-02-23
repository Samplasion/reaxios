// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Assignment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Assignment _$AssignmentFromJson(Map<String, dynamic> json) => Assignment(
      date: const DateSerializer().fromJson(json['data'] as String),
      publicationDate:
          const DateSerializer().fromJson(json['data_pubblicazione'] as String),
      subject: json['descMat'] as String,
      lessonHour: const IntSerializer().fromJson(json['oreLezione'] as String),
      id: json['idCompito'] as String,
      assignment: json['descCompiti'] as String,
    );

Map<String, dynamic> _$AssignmentToJson(Assignment instance) =>
    <String, dynamic>{
      'data': const DateSerializer().toJson(instance.date),
      'data_pubblicazione':
          const DateSerializer().toJson(instance.publicationDate),
      'descMat': instance.subject,
      'oreLezione': const IntSerializer().toJson(instance.lessonHour),
      'idCompito': instance.id,
      'descCompiti': instance.assignment,
    };

APIAssignments _$APIAssignmentsFromJson(Map<String, dynamic> json) =>
    APIAssignments(
      idAlunno: json['idAlunno'] as String,
      compiti: (json['compiti'] as List<dynamic>)
          .map((e) => Assignment.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$APIAssignmentsToJson(APIAssignments instance) =>
    <String, dynamic>{
      'idAlunno': instance.idAlunno,
      'compiti': instance.compiti,
    };
