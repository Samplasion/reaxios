// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Note.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Note _$NoteFromJson(Map<String, dynamic> json) => Note(
      date: const DateSerializer().fromJson(json['data'] as String),
      content: json['descNota'] as String,
      rawKind: const NoteKindSerializer().fromJson(json['tipo'] as String),
      id: json['idNota'] as String,
      subjectID: json['idMat'] as String,
      subject: json['descMat'] as String,
      teacher: json['descDoc'] as String,
    );

Map<String, dynamic> _$NoteToJson(Note instance) => <String, dynamic>{
      'data': const DateSerializer().toJson(instance.date),
      'descNota': instance.content,
      'tipo': const NoteKindSerializer().toJson(instance.rawKind),
      'idNota': instance.id,
      'idMat': instance.subjectID,
      'descMat': instance.subject,
      'descDoc': instance.teacher,
    };

APINotes _$APINotesFromJson(Map<String, dynamic> json) => APINotes(
      idAlunno: json['idAlunno'] as String,
      idFrazione: json['idFrazione'] as String,
      descFrazione: json['descFrazione'] as String,
      note: (json['note'] as List<dynamic>)
          .map((e) => Note.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$APINotesToJson(APINotes instance) => <String, dynamic>{
      'idAlunno': instance.idAlunno,
      'idFrazione': instance.idFrazione,
      'descFrazione': instance.descFrazione,
      'note': instance.note,
    };
