import 'package:flutter/material.dart';

class ConditionalChild extends StatelessWidget {
  final Widget child;
  final bool show;
  final Duration duration;

  const ConditionalChild({
    required this.child,
    required this.show,
    this.duration = const Duration(milliseconds: 300),
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedCrossFade(
      firstChild: Container(),
      secondChild: child,
      crossFadeState:
          show ? CrossFadeState.showSecond : CrossFadeState.showFirst,
      duration: duration,
    );
  }
}
