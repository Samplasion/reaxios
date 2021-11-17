import 'dart:math';

import 'package:flutter/material.dart';
import 'package:reaxios/api/entities/Grade/Grade.dart';

String dateToString(
  DateTime date, {
  bool includeTime = false,
  bool includeSeconds = false,
  bool short = false,
  bool includeYear = true,
  bool includeMonth = true,
}) {
  String s = short
      ? "${pad(date.day)}${includeMonth ? "/${pad(date.month)}" : ""}${includeYear ? "/${pad(date.year)}" : ""}"
      : "${pad(date.day)} ${includeMonth ? getHumanMonth(date.month) : ""} ${includeYear ? pad(date.year) : ""}";
  if (includeTime) {
    s += " ${pad(date.hour)}:${pad(date.minute)}";
    if (includeSeconds) {
      s += ":${pad(date.second)}";
    }
  }
  return s.trim();
}

String getHumanMonth(int mon) {
  switch (mon) {
    case 1:
      return "gennaio";
    case 2:
      return "febbraio";
    case 3:
      return "marzo";
    case 4:
      return "aprile";
    case 5:
      return "maggio";
    case 6:
      return "giugno";
    case 7:
      return "luglio";
    case 8:
      return "agosto";
    case 9:
      return "settembre";
    case 10:
      return "ottobre";
    case 11:
      return "novembre";
    case 12:
      return "dicembre";
    default:
      return "MESE NON VALIDO";
  }
}

String pad(n, [int digits = 2]) {
  final val = pow(10, digits - 1);
  if (n < val)
    return "${"0"}$n";
  else
    return n.toString();
}

String gradeToString(dynamic grade) {
  if (grade is String && grade.trim().isEmpty) return "";

  double dblGrade = 0;
  if (isNaN(double.tryParse('$grade'.replaceAll(",", ".")) ?? double.nan))
    return '$grade';
  else
    dblGrade = double.parse('$grade'.replaceAll(",", "."));

  if (dblGrade == 10) return '10';

  if (dblGrade.floorToDouble() == dblGrade) return '${dblGrade.toInt()}';

  final dec = dblGrade % 1;
  if (dec >= 0 && dec <= 0.125)
    return '${dblGrade.floor().toInt()}';
  else if (dec > 0.125 && dec <= 0.375)
    return '${dblGrade.floor().toInt()}+';
  else if (dec > 0.375 && dec <= 0.625)
    return '${dblGrade.floor().toInt()}½';
  else if (dec > 0.625 && dec <= 0.875)
    return '${dblGrade.floor().toInt() + 1}-';
  else
    return '${dblGrade.floor().toInt() + 1}';
}

/// Source: https://pages.collegeboard.org/how-to-convert-gpa-4.0-scale
String gradeToLetter(dynamic grade) {
  if (grade is String && grade.trim() == "") return '';

  double dblGrade = 0;
  if (isNaN(double.tryParse('$grade'.replaceAll(",", ".")) ?? double.nan))
    return '$grade';
  else
    dblGrade = double.parse('$grade'.replaceAll(",", "."));

  if (dblGrade == 0) return '$grade';

  // Round to account for floating point errors
  // (e.g. 66.9999999 (D) instead of 67 (D+))
  final percent = (dblGrade * 10).round();

  debugPrint(percent.toString());

  if (percent >= 97)
    return 'A+';
  else if (percent >= 93)
    return 'A';
  else if (percent >= 90)
    return 'A-';
  else if (percent >= 87)
    return 'B+';
  else if (percent >= 83)
    return 'B';
  else if (percent >= 80)
    return 'B-';
  else if (percent >= 77)
    return 'C+';
  else if (percent >= 73)
    return 'C';
  else if (percent >= 70)
    return 'C-';
  else if (percent >= 67)
    return 'D+';
  else if (percent >= 65)
    return 'D';
  else if (percent >= 60)
    return 'D-';
  else if (percent >= 50)
    return 'E';
  else if (percent >= 1)
    return 'F';
  else
    return 'N/A';
}

bool isNaN(double d) {
  return d != d || d == double.nan;
}

double gradeAverage(List<Grade> grades) {
  double sum = 0, weights = 0;

  grades.where((grade) => grade.weight != 0).forEach((g) {
    sum += g.grade * g.weight;
    weights += g.weight;
  });

  return double.parse((sum / weights).toStringAsFixed(2));
}

Color getGradeColor(double grade, [int shade = 500, int suff = 6]) {
  if (isNaN(grade)) return Colors.blue[shade]!;
  if (grade < suff)
    return Colors.red[shade]!;
  else if (grade < suff + 0.5)
    return Colors.orange[shade]!;
  else
    return Colors.green[shade]!;
}

Color? getColorIfNonZero(num num) {
  if (num == 0) return null;
  return Colors.red[400];
}

String formatNumber(num number) {
  if (number % 1 == 0) return number.toInt().toString();
  return num.parse(number.toStringAsFixed(2)).toString();
}

double simpleAverage(List<num> numbers) {
  return numbers.fold<num>(0, (prev, cur) => (prev) + cur) / numbers.length;
}

Color getContrastText(
  Color color, {
  Color darkBg = Colors.white,
  Color lightBg = Colors.black,
}) {
  return color.computeLuminance() > 0.5 ? lightBg : darkBg;
}

String titleCase(String str) {
  final tc = (str) => str[0].toUpperCase() + str.substring(1).toLowerCase();
  return str.split(" ").map(tc).join(" ");
}

extension ListRepeat<T> on List<T> {
  List<T> repeat(int times) {
    List<T> source = this;
    for (int time = 0; time < times; time++) source = source + this;
    return source;
  }
}
