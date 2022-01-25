import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Weekday implements Comparable {
  final int value;
  final int week;

  Weekday._(this.value, this.week)
      : assert(value >= 1 && value <= 7),
        assert(week >= 1 && week <= 4);

  static Map<int, List<Weekday>> days = {
    1: [1, 2, 3, 4, 5, 6, 7].map((e) => Weekday._(e, 1)).toList(),
    2: [1, 2, 3, 4, 5, 6, 7].map((e) => Weekday._(e, 1)).toList() +
        [1, 2, 3, 4, 5, 6, 7].map((e) => Weekday._(e, 2)).toList(),
    3: [1, 2, 3, 4, 5, 6, 7].map((e) => Weekday._(e, 1)).toList() +
        [1, 2, 3, 4, 5, 6, 7].map((e) => Weekday._(e, 2)).toList() +
        [1, 2, 3, 4, 5, 6, 7].map((e) => Weekday._(e, 3)).toList(),
    4: [1, 2, 3, 4, 5, 6, 7].map((e) => Weekday._(e, 1)).toList() +
        [1, 2, 3, 4, 5, 6, 7].map((e) => Weekday._(e, 2)).toList() +
        [1, 2, 3, 4, 5, 6, 7].map((e) => Weekday._(e, 3)).toList() +
        [1, 2, 3, 4, 5, 6, 7].map((e) => Weekday._(e, 4)).toList(),
  };

  factory Weekday(int week) => Weekday.fromDateTime(DateTime.now(), week);
  factory Weekday.fromDateTime(DateTime dt, int week) {
    return Weekday._(dt.weekday, week);
  }
  factory Weekday.get(int wd, int week) {
    if (week < 1 || week > 4) {
      throw RangeError.range(week, 1, 4);
    }
    if (wd <= 7 && wd >= 0) return Weekday._(wd, week);
    throw RangeError.range(wd, 1, 7);
  }

  String toShortString(String locale) {
    return DateFormat.E(locale).format(toDateTime);
  }

  String toLongString(String locale) {
    return DateFormat.EEEE(locale).format(toDateTime);
  }

  String toString() {
    throw UnimplementedError();
    // return DateFormat.EEEE().format(toDateTime);
  }

  @override
  int get hashCode => hashValues(value, week);

  @override
  bool operator ==(Object other) {
    if (other is Weekday) {
      return value == other.value;
    } else {
      return false;
    }
  }

  @override
  int compareTo(other) {
    if (other is! Weekday) return 0;
    return value - other.value;
  }

  Weekday get next {
    int nextValue = value + 1;
    int week = this.week;
    if (nextValue > 7) {
      nextValue = 1;
      week++;
      if (week > 4) week = 1;
    }
    return Weekday._(nextValue, week);
  }

  Weekday get previous {
    int prevValue = value - 1;
    int week = this.week;
    if (prevValue < 1) {
      prevValue = 7;
      week--;
      if (week < 1) week = 4;
    }
    return Weekday._(prevValue, week);
  }

  DateTime get toDateTime {
    // March 2021 has a nice mapping of
    // 1: Monday, 2: Tuesday, ecc...
    return DateTime(2021, 2, 28, 0, 0, 0).add(Duration(days: value));
  }

  Weekday copyWith({int? week}) {
    return Weekday._(value, week ?? this.week);
  }
}
