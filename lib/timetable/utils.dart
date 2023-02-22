// Matches before a capital letter that is not also at beginning of string.
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'structures/DayTime.dart';

final beforeNonLeadingCapitalLetter = RegExp(r"(?=(?!^)[A-Z])");

isSmall(context) => MediaQuery.of(context).size.width < 320.0;

/// Splits a PascalCase string into its words.
///
/// ```dart
/// splitPascalCase("MyAwesome String") // => "My Awesome String"
/// ```
/// [Source](https://stackoverflow.com/a/53719052)
List<String> splitPascalCase(String input) =>
    input.split(beforeNonLeadingCapitalLetter);

String generateAbbreviation(
  int length,
  String input, {
  List<String> ignoreList = const [],
}) {
  if (input.toUpperCase().replaceAll(RegExp(r"[^A-Z0-9]"), "").length <=
      length) {
    var base = input.toUpperCase().replaceAll(RegExp(r"[^A-Z0-9]"), "");
    for (int i = base.length; i < length; i++) base += "X";
    return base;
  }

  var words = splitPascalCase(input)
      .join(" ")
      .split(RegExp("[\\s'\"]"))
      .where((element) => !ignoreList.contains(element.toLowerCase()))
      .where((element) => element.trim().isNotEmpty)
      .toList();

  Logger.d("$words");

  var out = "";
  if (words.length >= length) {
    for (var word in words) {
      if (out.length < length) {
        out += word[0];
      }
    }
  } else {
    var coefficient = (length / words.length).round();
    for (var word in words) {
      for (var i = 0; i < coefficient && out.length < length; i++) {
        out += word[i];
      }
    }
  }

  return out.toUpperCase().replaceAll(RegExp(r"[^A-Z0-9]"), "");
}

Color getContrastColor(Color base) {
  if (base.computeLuminance() >= 0.5) {
    return Colors.black;
  } else {
    return Colors.white;
  }
}

const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
Random _rnd = Random();

String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
    length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

extension UsefulUtils on DateTime {
  DateTime get next {
    return DateTime(
      year,
      month,
      day + 1,
      hour,
      minute,
      second,
      millisecond,
      microsecond,
    );
  }
}

class DateTimeUtils {
  static getFirstDayOfWeek([DateTime? now]) {
    now ??= DateTime.now();

    if (now.weekday == 1) return now;

    return DateTime(
      now.year,
      now.month,
      now.day - now.weekday + 1,
      now.hour,
      now.minute,
      now.second,
      now.millisecond,
      now.microsecond,
    );
  }

  static dayTimeToDateTime(DayTime dt, [DateTime? time]) {
    return dt.toDateTime(time);
  }
}
