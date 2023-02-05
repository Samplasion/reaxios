import 'package:flutter/material.dart';
import 'package:reaxios/utils/utils.dart';

class GradientCircleAvatar extends StatelessWidget {
  const GradientCircleAvatar({
    Key? key,
    required this.color,
    this.foregroundColor,
    this.child,
    this.strength = 1.5,
    this.radius = 20,
  }) : super(key: key);

  final Color color;
  final Color? foregroundColor;
  final Widget? child;
  final double strength;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final fg = foregroundColor ?? color.contrastText;

    return CircleAvatar(
      radius: radius,
      foregroundColor: fg,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
            colors: getGradient(context, color, strength: strength),
          ),
        ),
        child: Center(
          child: child,
        ),
      ),
    );
  }
}
