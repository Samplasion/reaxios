// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Material.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MaterialData _$MaterialDataFromJson(Map<String, dynamic> json) => MaterialData(
      id: json['idContent'] as int,
      description: json['descrizione'] as String,
      rawText: json['testo'] as String,
      date: const DateSerializer().fromJson(json['data'] as String),
      url: json['url'] as String,
      fileName: json['file_name'] as String,
      fileUrl: json['file_url'] as String,
    );

Map<String, dynamic> _$MaterialDataToJson(MaterialData instance) =>
    <String, dynamic>{
      'idContent': instance.id,
      'descrizione': instance.description,
      'testo': instance.rawText,
      'data': const DateSerializer().toJson(instance.date),
      'url': instance.url,
      'file_name': instance.fileName,
      'file_url': instance.fileUrl,
    };

MaterialFolderData _$MaterialFolderDataFromJson(Map<String, dynamic> json) =>
    MaterialFolderData(
      id: json['idFolder'] as String,
      description: json['descrizione'] as String,
      rawNote: json['note'] as String,
      path: json['path'] as String,
    );

Map<String, dynamic> _$MaterialFolderDataToJson(MaterialFolderData instance) =>
    <String, dynamic>{
      'idFolder': instance.id,
      'descrizione': instance.description,
      'note': instance.rawNote,
      'path': instance.path,
    };

MaterialTeacherData _$MaterialTeacherDataFromJson(Map<String, dynamic> json) =>
    MaterialTeacherData(
      id: json['idDocente'] as String,
      name: json['nome'] as String,
      subjects: json['materie'] as String,
      folders: (json['folders'] as List<dynamic>)
          .map((e) => MaterialFolderData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$MaterialTeacherDataToJson(
        MaterialTeacherData instance) =>
    <String, dynamic>{
      'idDocente': instance.id,
      'nome': instance.name,
      'materie': instance.subjects,
      'folders': instance.folders,
    };

APIMaterials _$APIMaterialsFromJson(Map<String, dynamic> json) => APIMaterials(
      idAlunno: json['idAlunno'] as String,
      docenti: (json['docenti'] as List<dynamic>)
          .map((e) => MaterialTeacherData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$APIMaterialsToJson(APIMaterials instance) =>
    <String, dynamic>{
      'idAlunno': instance.idAlunno,
      'docenti': instance.docenti,
    };
