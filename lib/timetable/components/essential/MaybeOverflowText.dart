import 'package:flutter/material.dart';

class MaybeOverflowText extends StatelessWidget {
  final String fullwidth, short;
  final TextStyle? style;

  const MaybeOverflowText(this.fullwidth, this.short,
      {Key? key, required this.style})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, box) {
      if (!doesTextFit(fullwidth, 1, box, textStyle: style)) {
        return Text(
          fullwidth,
          style: style,
          maxLines: 1,
        );
      } else {
        return Text(
          short,
          style: style,
          maxLines: 1,
        );
      }
    });
  }

  bool doesTextFit(String text, int maxLines, BoxConstraints size,
      {TextStyle? textStyle}) {
    TextSpan span;
    if (textStyle == null) {
      span = TextSpan(
        text: text,
      );
    } else {
      span = TextSpan(text: text, style: textStyle);
    }

    TextPainter tp = TextPainter(
      maxLines: maxLines,
      textAlign: TextAlign.left,
      textDirection: TextDirection.ltr,
      text: span,
    );

    tp.layout(maxWidth: size.maxWidth);

    return tp.didExceedMaxLines;
  }
}
