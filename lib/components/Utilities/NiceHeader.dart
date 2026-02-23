import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';

class NiceHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? leading;

  const NiceHeader({
    Key? key,
    required this.title,
    required this.subtitle,
    this.leading,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (leading != null) ...[
          if (leading is Icon)
            (leading as Icon).iconSize(40).padding(right: 16)
          else
            leading!.padding(right: 16),
        ],
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: TextStyle(
                fontFamily: Theme.of(context).textTheme.titleLarge!.fontFamily,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ).padding(bottom: 8),
            Text(
              subtitle,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodySmall!.color,
                fontSize: 12,
              ),
            ),
          ],
        )
      ],
    ).padding(bottom: 8);
  }
}
