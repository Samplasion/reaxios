import 'package:flutter/material.dart';

class M3Divider extends StatelessWidget {
  const M3Divider({
    super.key,
    this.height,
    this.thickness,
    this.indent,
    this.endIndent,
  });

  factory M3Divider.drawer() => M3Divider(
        height: 33,
        indent: 28,
        endIndent: 28,
      );

  final double? height;
  final double? thickness;
  final double? indent;
  final double? endIndent;

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: height,
      thickness: thickness,
      indent: indent,
      endIndent: endIndent,
      color: Theme.of(context).colorScheme.outlineVariant,
    );
  }
}
