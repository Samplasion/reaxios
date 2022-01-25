// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Event.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

extension EventCopyWith on Event {
  Event copyWith({
    String? abbr,
    Color? color,
    DayTime? end,
    List<String>? ignoreList,
    String? name,
    String? notes,
    DayTime? start,
    Weekday? weekday,
  }) {
    return Event(
      abbr: abbr ?? this.abbr,
      color: color ?? this.color,
      end: end ?? this.end,
      ignoreList: ignoreList ?? this.ignoreList,
      name: name ?? this.name,
      notes: notes ?? this.notes,
      start: start ?? this.start,
      weekday: weekday ?? this.weekday,
    );
  }
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Event _$EventFromJson(Map<String, dynamic> json) => Event(
      name: json['name'] as String,
      notes: json['notes'] as String,
      start: TimeOfDayConverter().fromJson(json['start'] as int),
      end: TimeOfDayConverter().fromJson(json['end'] as int),
      color: ColorConverter().fromJson(json['color'] as int),
      weekday: WeekdayConverter().fromJson(json['weekday'] as int),
      abbr: json['abbr'] as String? ?? "",
    );

Map<String, dynamic> _$EventToJson(Event instance) => <String, dynamic>{
      'name': instance.name,
      'notes': instance.notes,
      'start': TimeOfDayConverter().toJson(instance.start),
      'end': TimeOfDayConverter().toJson(instance.end),
      'color': ColorConverter().toJson(instance.color),
      'weekday': WeekdayConverter().toJson(instance.weekday),
      'abbr': instance.abbr,
    };
