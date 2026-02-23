import 'package:flutter/material.dart';

class EmptyUI extends StatelessWidget {
  final IconData icon;
  final String text;
  final String? subtitle;

  const EmptyUI({
    Key? key,
    required this.icon,
    required this.text,
    this.subtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final caption = Theme.of(context).textTheme.bodySmall;
    return Container(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 72, color: caption?.color),
            Text(text + (subtitle == null ? "" : "\n\n$subtitle"),
                style: caption, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
