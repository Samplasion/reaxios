// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'School.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

School _$SchoolFromJson(Map<String, dynamic> json) {
  return School(
    id: json['fsCF'] as String,
    title: json['fsIntitolazione'] as String,
    name: json['fsNome'] as String,
    zipCode: json['fsCap'] as String,
    region: json['fsRegione'] as String,
    city: json['fsCitta'] as String,
    province: json['fsProvincia'] as String,
  );
}

Map<String, dynamic> _$SchoolToJson(School instance) => <String, dynamic>{
      'fsIntitolazione': instance.title,
      'fsNome': instance.name,
      'fsCF': instance.id,
      'fsCap': instance.zipCode,
      'fsRegione': instance.region,
      'fsCitta': instance.city,
      'fsProvincia': instance.province,
    };
