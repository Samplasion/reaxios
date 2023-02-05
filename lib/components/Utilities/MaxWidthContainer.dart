import 'package:flutter/material.dart';

import '../../utils/consts.dart';

class MaxWidthContainer extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final bool strict;

  const MaxWidthContainer({
    Key? key,
    required this.child,
    this.maxWidth = kTabBreakpoint,
    this.strict = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (strict) {
      return ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth,
        ),
        child: child,
      );
    }
    return Container(
      width: maxWidth,
      child: child,
    );
  }
}
