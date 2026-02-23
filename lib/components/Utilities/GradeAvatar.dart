import 'package:flutter/material.dart';
import 'package:axios_api/entities/Grade/Grade.dart';
import 'package:reaxios/components/LowLevel/GradientCircleAvatar.dart';
import 'package:reaxios/utils/utils.dart';

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

  Color getColor(BuildContext context) {
    if (grade.weight == 0)
      return context.harmonize(color: Colors.blue);
    else
      return getGradeColor(context, grade.grade);
  }

  @override
  Widget build(BuildContext context) {
    final bg = getColor(context);

    final text = grade.getPrettyGrade(context).trim();
    final child = text.isEmpty
        ? (showIconIfNaN ? Icon(Icons.message) : Container())
        : Text(
            text,
            style: TextStyle(
              fontFamily: Theme.of(context).textTheme.bodyMedium!.fontFamily,
            ),
          );

    return GradientCircleAvatar(
      radius: radius,
      child: child,
      color: bg,
    );
  }
}
