import 'package:flutter/material.dart';

import '../../extensions.dart';

class GradientCircleAvatar extends StatelessWidget {
  final List<Color> colors;
  final double radius;

  GradientCircleAvatar({
    this.radius = 20,
    List<Color>? colors,
    Color? color,
    Key? key,
  })  : assert(color != null || colors != null && colors.isNotEmpty),
        colors = colors ?? color!.toSlightGradient(),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.transparent,
      child: ClipOval(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: colors,
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
            ),
          ),
        ),
      ),
    );
  }
}
