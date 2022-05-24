import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import '../converters/Color.dart';
import '../converters/TimeOfDay.dart';
import '../converters/Weekday.dart';
import '../utils.dart';
import 'DayTime.dart';
import 'Weekday.dart';

part 'Event.g.dart';

@JsonSerializable(explicitToJson: true)
class Event {
  final String name, notes;

  @TimeOfDayConverter()
  final DayTime start, end;

  @ColorConverter()
  final Color color;

  @WeekdayConverter()
  final Weekday weekday;
  String abbr;

  @JsonKey(ignore: true)
  final List<String> ignoreList;

  Event({
    required this.name,
    required this.notes,
    required this.start,
    required this.end,
    required this.color,
    required this.weekday,
    this.abbr = "",
    this.ignoreList = const [],
  }) {
    if (abbr.isEmpty) {
      abbr = generateAbbreviation(3, name, ignoreList: ignoreList);
    }
  }

  Event copyWith({
    String? name,
    String? notes,
    DayTime? start,
    DayTime? end,
    Color? color,
    Weekday? weekday,
    String? abbr,
    List<String>? ignoreList,
  }) {
    return Event(
      name: name ?? this.name,
      notes: notes ?? this.notes,
      start: start ?? this.start,
      end: end ?? this.end,
      color: color ?? this.color,
      weekday: weekday ?? this.weekday,
      abbr: abbr ?? this.abbr,
      ignoreList: ignoreList ?? this.ignoreList,
    );
  }

  Event cloneWith({
    String? name,
    String? notes,
    DayTime? start,
    DayTime? end,
    Color? color,
    Weekday? weekday,
    String? abbr,
  }) {
    return Event(
      name: name ?? this.name,
      notes: notes ?? this.notes,
      start: start ?? this.start,
      end: end ?? this.end,
      color: color ?? this.color,
      weekday: weekday ?? this.weekday,
      abbr: abbr ?? this.abbr,
      ignoreList: [],
    );
  }

  @override
  int get hashCode {
    return hashValues(name, notes, start, end, color, weekday);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is Event) {
      return name == other.name &&
          notes == other.notes &&
          start == other.start &&
          end == other.end &&
          color == other.color &&
          weekday == other.weekday;
    } else {
      return false;
    }
  }

  bool isBefore(Event other) {
    return weekday.value < other.weekday.value ||
        (weekday.value == other.weekday.value && start < other.start);
  }

  bool isAfter(Event other) {
    return weekday.value > other.weekday.value ||
        (weekday.value == other.weekday.value && start > other.start);
  }

  factory Event.fromJson(Map<String, dynamic> json) => _$EventFromJson(json);
  Map<String, dynamic> toJson() => _$EventToJson(this);

  bool get isValid {
    if (start > end) {
      return false;
    }
    return name.isNotEmpty && abbr.isNotEmpty;
  }
}

class EventTransformation {
  String? name, abbr;
  Color? color;

  EventTransformation({
    this.name,
    this.abbr,
    this.color,
  });

  factory EventTransformation.fromEvent(Event event) {
    return EventTransformation(
      name: event.name,
      abbr: event.abbr,
      color: event.color,
    );
  }

  Event apply(Event event) {
    return event.cloneWith(
      color: color,
      abbr: abbr,
      name: name,
    );
  }
}
