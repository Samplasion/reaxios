// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Student.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Student _$StudentFromJson(Map<String, dynamic> json) => Student(
      avatar: json['avatar'] as String,
      birthday: const DateSerializer().fromJson(json['dataNascita'] as String),
      id: (json['id'] as num?)?.toInt(),
      firstName: json['nome'] as String,
      lastName: json['cognome'] as String,
      parentID: json['userId'] as String,
      gender: const GenderSerializer().fromJson(json['sesso'] as String),
      justifiable:
          const BooleanSerializer().fromJson(json['flagGiustifica'] as String),
      schoolUUID: json['idPlesso'] as String,
      securityBits: json['security'] as String,
      studentUUID: json['idAlunno'] as String,
    );

Map<String, dynamic> _$StudentToJson(Student instance) => <String, dynamic>{
      'avatar': instance.avatar,
      'nome': instance.firstName,
      'cognome': instance.lastName,
      'dataNascita': const DateSerializer().toJson(instance.birthday),
      'flagGiustifica': const BooleanSerializer().toJson(instance.justifiable),
      'idAlunno': instance.studentUUID,
      'idPlesso': instance.schoolUUID,
      'security': instance.securityBits,
      'sesso': const GenderSerializer().toJson(instance.gender),
      'id': instance.id,
      'userId': instance.parentID,
    };
