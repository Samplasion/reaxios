import 'package:flutter/material.dart';
import 'package:reaxios/api/entities/Grade/Grade.dart';
import 'package:reaxios/api/utils/utils.dart';
import 'package:reaxios/utils.dart';

class GradeAvatar extends StatelessWidget {
  const GradeAvatar({
    Key? key,
    required this.grade,
    this.showIconIfNaN = true,
    this.radius = 20,
  }) : super(key: key);

  final Grade grade;
  final bool showIconIfNaN;
  final double radius;

  Color getColor() {
    if (grade.weight == 0)
      return Colors.blue;
    else
      return getGradeColor(grade.grade);
  }

  @override
  Widget build(BuildContext context) {
    final bg = getColor();
    final fg = bg.contrastText;

    final text = grade.prettyGrade.trim();
    final child = text.isEmpty
        ? (showIconIfNaN ? Icon(Icons.message) : Container())
        : Text(text);

    return CircleAvatar(
      radius: radius,
      backgroundColor: bg,
      foregroundColor: fg,
      child: child,
    );
  }
}
