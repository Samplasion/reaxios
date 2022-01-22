import 'package:flutter/material.dart';

import '../../consts.dart';

class MaxWidthContainer extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const MaxWidthContainer({
    Key? key,
    required this.child,
    this.maxWidth = kTabBreakpoint,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: maxWidth,
      child: child,
    );
  }
}
