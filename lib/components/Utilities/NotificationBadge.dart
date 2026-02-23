import 'package:flutter/material.dart';
import 'package:reaxios/utils/utils.dart';

class NotificationBadge extends StatelessWidget {
  const NotificationBadge({
    Key? key,
    required this.child,
    required this.showBadge,
    this.background = const Color(0),
    this.foreground,
    this.alignment = Alignment.centerLeft,
    this.rightOffset = 0,
  }) : super(key: key);

  final Widget child;
  final bool showBadge;
  final Color? background;
  final Color? foreground;
  final AlignmentGeometry alignment;
  final double rightOffset;

  @override
  Widget build(BuildContext context) {
    final fg = foreground != null
        ? context.harmonize(color: foreground!)
        : Theme.of(context).colorScheme.error;
    return Stack(
      alignment: alignment,
      children: [
        child,
        if (showBadge)
          Positioned(
            top: 0,
            right: rightOffset,
            child: Container(
              width: 9,
              height: 9,
              child: CircleAvatar(
                backgroundColor: fg,
              ),
            ),
          ),
      ],
    );
  }
}
