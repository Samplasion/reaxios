import 'package:flutter/material.dart';
import 'package:reaxios/api/utils/utils.dart';
import 'package:reaxios/utils.dart';

class GradeText extends TextSpan {
  GradeText(
    BuildContext context, {
    required double grade,
    bool precise = true,
    bool showNumericValue = false,
    String? label,
    int shade = 400,
  }) : super(
          // text: label == null
          //     ? (precise
          //         ? formatNumber(grade)
          //         : context.gradeToString(grade, round: precise))
          text: label == null
              ? (showNumericValue
                  ? formatNumber(grade)
                  : context.gradeToString(grade, round: precise))
              : label,
          style: TextStyle(
            color: getGradeColor(context, grade, shade),
            fontWeight: FontWeight.bold,
          ),
        );
}
