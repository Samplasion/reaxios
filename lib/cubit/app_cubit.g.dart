// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_cubit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppState _$AppStateFromJson(Map<String, dynamic> json) => AppState(
      testMode: json['testMode'] as bool,
      axios: _$JsonConverterFromJson<Map<String, dynamic>, Axios?>(
          json['axios'], const AxiosConverter().fromJson),
      school: json['school'] == null
          ? null
          : School.fromJson(json['school'] as Map<String, dynamic>),
      assignments: (json['assignments'] as List<dynamic>?)
          ?.map((e) => Assignment.fromJson(e as Map<String, dynamic>))
          .toList(),
      grades: (json['grades'] as List<dynamic>?)
          ?.map((e) => Grade.fromJson(e as Map<String, dynamic>))
          .toList(),
      topics: (json['topics'] as List<dynamic>?)
          ?.map((e) => Topic.fromJson(e as Map<String, dynamic>))
          .toList(),
      reportCards: (json['reportCards'] as List<dynamic>?)
          ?.map((e) => ReportCard.fromJson(e as Map<String, dynamic>))
          .toList(),
      bulletins: (json['bulletins'] as List<dynamic>?)
          ?.map((e) => Bulletin.fromJson(e as Map<String, dynamic>))
          .toList(),
      notes: (json['notes'] as List<dynamic>?)
          ?.map((e) => Note.fromJson(e as Map<String, dynamic>))
          .toList(),
      absences: (json['absences'] as List<dynamic>?)
          ?.map((e) => Absence.fromJson(e as Map<String, dynamic>))
          .toList(),
      authorizations: (json['authorizations'] as List<dynamic>?)
          ?.map((e) => Authorization.fromJson(e as Map<String, dynamic>))
          .toList(),
      materials: (json['materials'] as List<dynamic>?)
          ?.map((e) => MaterialTeacherData.fromJson(e as Map<String, dynamic>))
          .toList(),
      meetings: (json['meetings'] as List<dynamic>?)
          ?.map((e) => MeetingSchema.fromJson(e as Map<String, dynamic>))
          .toList(),
      curricula: (json['curricula'] as List<dynamic>?)
          ?.map((e) => Curriculum.fromJson(e as Map<String, dynamic>))
          .toList(),
      structural: json['structural'] == null
          ? null
          : Structural.fromJson(json['structural'] as Map<String, dynamic>),
      student: json['student'] == null
          ? null
          : Student.fromJson(json['student'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AppStateToJson(AppState instance) => <String, dynamic>{
      'testMode': instance.testMode,
      'axios': const AxiosConverter().toJson(instance.axios),
      'school': instance.school,
      'assignments': instance.assignments,
      'grades': instance.grades,
      'topics': instance.topics,
      'reportCards': instance.reportCards,
      'bulletins': instance.bulletins,
      'notes': instance.notes,
      'absences': instance.absences,
      'authorizations': instance.authorizations,
      'materials': instance.materials,
      'meetings': instance.meetings,
      'curricula': instance.curricula,
      'structural': instance.structural,
      'student': instance.student,
    };

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) =>
    json == null ? null : fromJson(json as Json);
