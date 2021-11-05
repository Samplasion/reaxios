import 'package:flutter/material.dart';
import 'package:reaxios/api/utils/utils.dart';

class GradeText extends TextSpan {
  GradeText({
    required double grade,
    bool precise = true,
    String? label,
    int shade = 400,
  }) : super(
          text: label == null
              ? (precise ? formatNumber(grade) : gradeToString(grade))
              : label,
          style: TextStyle(
            color: getGradeColor(grade, shade),
            fontWeight: FontWeight.bold,
          ),
        );
}
