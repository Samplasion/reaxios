// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Login.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Login _$LoginFromJson(Map<String, dynamic> json) => Login(
      avatar: json['avatar'] as String,
      birthday: const DateSerializer().fromJson(json['dataNascita'] as String),
      schoolID: json['customerId'] as String,
      schoolName: json['customerName'] as String,
      schoolTitle: json['customerTitle'] as String,
      id: json['id'] as int,
      firstName: json['nome'] as String,
      lastName: json['cognome'] as String,
      userID: json['userId'] as String,
      password: json['userPassword'] as String,
      pin: json['userPinRe'] as String,
      kind: json['gruppiAppartenenza'] as String,
      sessionUUID: json['usersession'] as String,
    );

Map<String, dynamic> _$LoginToJson(Login instance) => <String, dynamic>{
      'avatar': instance.avatar,
      'customerId': instance.schoolID,
      'customerName': instance.schoolName,
      'customerTitle': instance.schoolTitle,
      'dataNascita': const DateSerializer().toJson(instance.birthday),
      'nome': instance.firstName,
      'cognome': instance.lastName,
      'id': instance.id,
      'userId': instance.userID,
      'userPassword': instance.password,
      'userPinRe': instance.pin,
      'gruppiAppartenenza': instance.kind,
      'usersession': instance.sessionUUID,
    };
