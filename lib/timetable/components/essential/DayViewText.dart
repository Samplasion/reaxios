import 'package:flutter/material.dart';

class DayViewText extends StatelessWidget {
  final String text;

  const DayViewText(this.text, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        text.toUpperCase(),
        style: Theme.of(context).textTheme.caption,
        textAlign: TextAlign.center,
        maxLines: 1,
      ),
    );
  }
}
