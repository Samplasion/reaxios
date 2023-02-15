import 'package:flutter/widgets.dart';

class RegistroValues {
  static const cardRadius = 13.0;
  static const tinyCardRadius = 2.5;

  static const padding = 16.0;
  static const interCardPadding = 1.5;

  static BorderRadius getRadius(
    bool isFirst,
    bool isLast, {
    double smallRadius = tinyCardRadius,
    double largeRadius = cardRadius,
  }) =>
      BorderRadius.vertical(
        top: isFirst
            ? Radius.circular(largeRadius)
            : Radius.circular(smallRadius),
        bottom: isLast
            ? Radius.circular(largeRadius)
            : Radius.circular(smallRadius),
      );
}
