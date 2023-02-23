// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Authorization.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Authorization _$AuthorizationFromJson(Map<String, dynamic> json) =>
    Authorization(
      id: json['idPermesso'] as String,
      rawKind: json['tipo'] as String,
      startDate: const DateSerializer().fromJson(json['dataInizio'] as String),
      endDate: const DateSerializer().fromJson(json['dataFine'] as String),
      rawLessonHour: const IntSerializer().fromJson(json['ora'] as String),
      time: const DateSerializer().fromJson(json['orario'] as String),
      reason: json['motivo'] as String,
      notes: json['note'] as String,
      concurs: const BooleanSerializer().fromJson(json['calcolo'] as String),
      entireClass: const BooleanSerializer().fromJson(json['classe'] as String),
      insertedBy: json['utenteInserimento'] as String,
      authorizedBy: json['utenteAutorizzazione'] as String,
      authorizedDate:
          const DateSerializer().fromJson(json['dataAutorizzazione'] as String),
    );

Map<String, dynamic> _$AuthorizationToJson(Authorization instance) =>
    <String, dynamic>{
      'idPermesso': instance.id,
      'tipo': instance.rawKind,
      'dataInizio': const DateSerializer().toJson(instance.startDate),
      'dataFine': const DateSerializer().toJson(instance.endDate),
      'ora': const IntSerializer().toJson(instance.rawLessonHour),
      'orario': const DateSerializer().toJson(instance.time),
      'motivo': instance.reason,
      'note': instance.notes,
      'calcolo': const BooleanSerializer().toJson(instance.concurs),
      'classe': const BooleanSerializer().toJson(instance.entireClass),
      'utenteInserimento': instance.insertedBy,
      'utenteAutorizzazione': instance.authorizedBy,
      'dataAutorizzazione':
          const DateSerializer().toJson(instance.authorizedDate),
    };

Request _$RequestFromJson(Map<String, dynamic> json) => Request();

Map<String, dynamic> _$RequestToJson(Request instance) => <String, dynamic>{};

APIAuthorizations _$APIAuthorizationsFromJson(Map<String, dynamic> json) =>
    APIAuthorizations(
      idAlunno: json['idAlunno'] as String,
      permessiDaAutorizzare: (json['permessiDaAutorizzare'] as List<dynamic>)
          .map((e) => Authorization.fromJson(e as Map<String, dynamic>))
          .toList(),
      permessiAutorizzati: (json['permessiAutorizzati'] as List<dynamic>)
          .map((e) => Authorization.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$APIAuthorizationsToJson(APIAuthorizations instance) =>
    <String, dynamic>{
      'idAlunno': instance.idAlunno,
      'permessiDaAutorizzare': instance.permessiDaAutorizzare,
      'permessiAutorizzati': instance.permessiAutorizzati,
    };
