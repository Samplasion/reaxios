// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Bulletin.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Bulletin _$BulletinFromJson(Map<String, dynamic> json) => Bulletin(
      id: json['id'] as String,
      date: const DateSerializer().fromJson(json['data'] as String),
      title: json['titolo'] as String,
      desc: json['desc'] as String,
      kind: const BulletinKindSerializer().fromJson(json['tipo'] as String),
      responseKind: json['tipo_risposta'] as String,
      options: json['opzioni'] as String,
      pin: const BooleanSerializer().fromJson(json['pin'] as String),
      editable:
          const BooleanSerializer().fromJson(json['modificabile'] as String),
      read: const BooleanSerializer().fromJson(json['letta'] as String),
      reply: json['risposta'] as String,
      textReply: json['risposta_testo'] as String,
      attachments: (json['allegati'] as List<dynamic>)
          .map((e) => BulletinAttachment.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$BulletinToJson(Bulletin instance) => <String, dynamic>{
      'id': instance.id,
      'data': const DateSerializer().toJson(instance.date),
      'titolo': instance.title,
      'desc': instance.desc,
      'tipo': const BulletinKindSerializer().toJson(instance.kind),
      'tipo_risposta': instance.responseKind,
      'opzioni': instance.options,
      'pin': const BooleanSerializer().toJson(instance.pin),
      'modificabile': const BooleanSerializer().toJson(instance.editable),
      'letta': const BooleanSerializer().toJson(instance.read),
      'risposta': instance.reply,
      'risposta_testo': instance.textReply,
      'allegati': instance.attachments,
    };

APIBulletins _$APIBulletinsFromJson(Map<String, dynamic> json) => APIBulletins(
      idAlunno: json['idAlunno'] as String,
      comunicazioni: (json['comunicazioni'] as List<dynamic>)
          .map((e) => Bulletin.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$APIBulletinsToJson(APIBulletins instance) =>
    <String, dynamic>{
      'idAlunno': instance.idAlunno,
      'comunicazioni': instance.comunicazioni,
    };

BulletinAttachment _$BulletinAttachmentFromJson(Map<String, dynamic> json) =>
    BulletinAttachment(
      kind: const BulletinAttachmentKindSerializer()
          .fromJson(json['tipo'] as String),
      url: json['URL'] as String,
      desc: json['desc'] as String?,
      sourceName: json['sourceName'] as String?,
    );

Map<String, dynamic> _$BulletinAttachmentToJson(BulletinAttachment instance) =>
    <String, dynamic>{
      'tipo': const BulletinAttachmentKindSerializer().toJson(instance.kind),
      'URL': instance.url,
      'desc': instance.desc,
      'sourceName': instance.sourceName,
    };
