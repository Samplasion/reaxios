import 'package:flutter/material.dart';

class _Tuple<T1, T2> {
  _Tuple(this.first, this.second);

  final T1 first;
  final T2 second;

  operator [](int idx) {
    if (idx == 0) return first;
    if (idx == 1) return second;
    return null;
  }
}

class DayTime extends TimeOfDay implements Comparable<DayTime> {
  DayTime({required int hour, required int minute})
      : super(
          hour: _getCorrectedMinutesAndSeconds(hour, minute)[0],
          minute: _getCorrectedMinutesAndSeconds(hour, minute)[1],
        );

  factory DayTime.fromTimeOfDay(TimeOfDay time) {
    return DayTime(hour: time.hour, minute: time.minute);
  }

  factory DayTime.now() {
    final now = DateTime.now();
    return DayTime(hour: now.hour, minute: now.minute);
  }

  static _Tuple<int, int> _getCorrectedMinutesAndSeconds(
      int hours, int minutes) {
    if (minutes >= TimeOfDay.minutesPerHour) {
      int newHours = (minutes / TimeOfDay.minutesPerHour).truncate();
      minutes %= TimeOfDay.minutesPerHour;
      hours += newHours;
    }

    hours %= TimeOfDay.hoursPerDay;

    return _Tuple(hours, minutes);
  }

  DayTime add(Duration duration) {
    var newTime =
        _getCorrectedMinutesAndSeconds(hour, minute + duration.inMinutes);
    return DayTime(hour: newTime[0], minute: newTime[1]);
  }

  int get inMinutes {
    return hour * TimeOfDay.minutesPerHour + minute;
  }

  operator <(DayTime other) {
    return inMinutes < other.inMinutes;
  }

  operator >(DayTime other) {
    return inMinutes > other.inMinutes;
  }

  DateTime toDateTime([DateTime? time]) {
    time ??= DateTime.now();

    return DateTime(
      time.year,
      time.month,
      time.day,
      hour,
      minute,
      time.second,
      time.millisecond,
      time.microsecond,
    );
  }

  String _pad(int value) {
    return value.toString().padLeft(2, '0');
  }

  @override
  String toString() {
    return '${_pad(hour)}:${_pad(minute)}';
  }

  @override
  int compareTo(DayTime other) {
    return inMinutes.compareTo(other.inMinutes);
  }
}
