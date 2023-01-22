import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';

class NotificationBadge extends StatelessWidget {
  const NotificationBadge({
    Key? key,
    required this.child,
    required this.showBadge,
    this.background = const Color(0),
    this.foreground = const Color(0xFFFF4444),
    this.alignment = Alignment.centerLeft,
    this.rightOffset = 0,
  }) : super(key: key);

  final Widget child;
  final bool showBadge;
  final Color? background;
  final Color foreground;
  final AlignmentGeometry alignment;
  final double rightOffset;

  @override
  Widget build(BuildContext context) {
    final bg = background ?? Theme.of(context).cardTheme.color!;
    return [
      child,
      if (showBadge)
        [
          Container(
            width: 12,
            height: 12,
            child: CircleAvatar(
              backgroundColor: bg,
            ),
          ),
          Container(
            width: 9,
            height: 9,
            child: CircleAvatar(
              backgroundColor: foreground,
            ),
          ),
        ]
            .toStack(alignment: Alignment.center)
            .positioned(top: 0, right: rightOffset),
    ].toStack(alignment: alignment);
  }
}
