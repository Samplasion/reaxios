// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Topic.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Topic _$TopicFromJson(Map<String, dynamic> json) {
  return Topic(
    date: const DateSerializer().fromJson(json['data'] as String),
    publicationDate:
        const DateSerializer().fromJson(json['data_pubblicazione'] as String),
    subject: json['descMat'] as String,
    lessonHour: json['oreLezione'] as String,
    id: json['idCollabora'] as String? ?? '',
    flags: json['flagStato'] as String,
    topic: json['descArgomenti'] as String? ?? '',
  );
}

Map<String, dynamic> _$TopicToJson(Topic instance) => <String, dynamic>{
      'data': const DateSerializer().toJson(instance.date),
      'descMat': instance.subject,
      'oreLezione': instance.lessonHour,
      'descArgomenti': instance.topic,
      'flagStato': instance.flags,
      'data_pubblicazione':
          const DateSerializer().toJson(instance.publicationDate),
      'idCollabora': instance.id,
    };

APITopics _$APITopicsFromJson(Map<String, dynamic> json) {
  return APITopics(
    idAlunno: json['idAlunno'] as String,
    argomenti: (json['argomenti'] as List<dynamic>)
        .map((e) => Topic.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

Map<String, dynamic> _$APITopicsToJson(APITopics instance) => <String, dynamic>{
      'idAlunno': instance.idAlunno,
      'argomenti': instance.argomenti,
    };
