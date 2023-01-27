import 'package:flutter/material.dart';

import '../../extensions.dart';

class GradientCircleAvatar extends StatelessWidget {
  final Color? color;
  final List<Color>? colors;
  final double radius;

  GradientCircleAvatar({
    this.radius = 20,
    this.colors,
    this.color,
    Key? key,
  })  : assert(color != null || colors != null && colors.isNotEmpty),
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
              colors: colors ?? color!.toSlightGradient(context),
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
            ),
          ),
        ),
      ),
    );
  }
}
