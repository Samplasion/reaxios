// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Event _$EventFromJson(Map<String, dynamic> json) => Event(
      name: json['name'] as String,
      notes: json['notes'] as String,
      start: const TimeOfDayConverter().fromJson(json['start'] as int),
      end: const TimeOfDayConverter().fromJson(json['end'] as int),
      color: const ColorConverter().fromJson(json['color'] as int),
      weekday: const WeekdayConverter().fromJson(json['weekday'] as int),
      abbr: json['abbr'] as String? ?? "",
    );

Map<String, dynamic> _$EventToJson(Event instance) => <String, dynamic>{
      'name': instance.name,
      'notes': instance.notes,
      'start': const TimeOfDayConverter().toJson(instance.start),
      'end': const TimeOfDayConverter().toJson(instance.end),
      'color': const ColorConverter().toJson(instance.color),
      'weekday': const WeekdayConverter().toJson(instance.weekday),
      'abbr': instance.abbr,
    };
