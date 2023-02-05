import 'dart:math';

import 'package:flutter/material.dart';
import 'package:reaxios/utils/utils.dart';
import 'structures/Event.dart';

extension RangeExtension on int {
  List<int> to(int maxInclusive, {int step = 1}) =>
      [for (int i = this; i <= maxInclusive; i += step) i];
}

extension ColorExtension on Color {
  Color lighten(double amount) => Color.lerp(this, Colors.white, amount)!;
  Color darken(double amount) => Color.lerp(this, Colors.black, amount)!;

  List<Color> toSlightGradient(BuildContext context) =>
      getGradient(context, this, strength: 2);

  Color get contrastColor => (0.299 * red + 0.587 * green + 0.114 * blue) < 186
      ? Colors.white
      : Colors.black;
}

extension ListExtension<T> on List<T> {
  List<T> unique<S>([S Function(T)? mapper]) {
    final seen = <S>{};
    return where((element) {
      final key = mapper != null ? mapper(element) : element as S;
      if (seen.contains(key)) {
        return false;
      } else {
        seen.add(key);
        return true;
      }
    }).toList();
  }

  T randomElement() => elementAt(Random().nextInt(length));

  List<T> operator *(int times) => [for (int i = 0; i < times; i++) ...this];

  Map<int, T> get entries {
    final map = <int, T>{};
    for (int i = 0; i < length; i++) {
      map[i] = elementAt(i);
    }
    return map;
  }
}

extension NullLogExtension on Null {
  void log() {
    print(this);
  }
}

extension ObjectLogExtension on Object {
  void log() {
    print(this);
  }
}

extension NextEventExtension on List<Event> {
  Event? getCurrentOrNextEvent([DateTime? now]) {
    now ??= DateTime.now();

    Event? next;
    for (final event in this) {
      if (event.end.toDateTime().isAfter(now)) {
        if ((next == null || event.start < next.start) &&
            event.weekday.value == now.weekday) {
          next = event;
        }
      }
    }

    return next;
  }

  List<Event> getTodayEvents([DateTime? now]) {
    now ??= DateTime.now();

    return where((event) {
      final start = event.start.toDateTime();
      final end = event.end.toDateTime();
      return event.weekday.value == now!.weekday &&
          start.isAfter(now) &&
          end.isAfter(now);
    }).toList()
      ..sort((a, b) => a.start.compareTo(b.start));
  }

  List<Event> getTomorrowEvents([DateTime? now]) {
    now ??= DateTime.now();

    return where((event) {
      return event.weekday.value == _sanitizeWeekday(now!.weekday + 1);
    }).toList()
      ..sort((a, b) => a.start.compareTo(b.start));
  }

  int _sanitizeWeekday(int wd) {
    if (wd < 1) {
      return wd + 7;
    } else if (wd > 7) {
      return wd - 7;
    } else {
      return wd;
    }
  }
}
