import 'package:flutter/material.dart';
import 'package:reaxios/api/entities/Grade/Grade.dart';
import 'package:reaxios/api/utils/utils.dart';
import 'package:reaxios/utils.dart';

class GradeAvatar extends StatelessWidget {
  const GradeAvatar({Key? key, required this.grade}) : super(key: key);

  final Grade grade;

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
    final child = text.isEmpty ? Icon(Icons.message) : Text(text);

    return CircleAvatar(
      backgroundColor: bg,
      foregroundColor: fg,
      child: child,
    );
  }
}
