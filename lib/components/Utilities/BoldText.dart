import 'package:flutter/material.dart';

class BoldText extends TextSpan {
  BoldText({required String text, Color? color})
      : super(
          text: text,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        );

  Text asText({
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
  }) =>
      Text.rich(
        this,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
      );
}
