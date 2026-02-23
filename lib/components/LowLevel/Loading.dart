import 'dart:math';

import 'package:flutter/material.dart' hide Gradient;
import 'package:reaxios/components/LowLevel/Gradient.dart';
import 'package:reaxios/utils/utils.dart';

class LoadingUI extends StatefulWidget {
  final bool colorful, showHints;
  final double? progress, outOf;

  LoadingUI({
    this.colorful = false,
    this.showHints = false,
    this.progress,
    this.outOf,
    Key? key,
  })  : assert((progress == null) == (outOf == null),
            "Either both 'progress' and 'outOf' must be null, or none"),
        super(key: key);

  @override
  _LoadingUIState createState() => _LoadingUIState();
}

class _LoadingUIState extends State<LoadingUI> {
  int randomIndex = Random().nextInt(100);

  List<String> getDidYouKnow(BuildContext context) =>
      context.loc.translate("main.didYouKnow").split("\n");

  @override
  Widget build(BuildContext context) {
    final list = getDidYouKnow(context);
    return Container(
      child: Stack(
        children: [
          if (widget.colorful)
            Gradient(colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondary,
            ]),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  value: () {
                    if (widget.progress != null)
                      return widget.progress! / widget.outOf!;
                  }(),
                  color: widget.colorful
                      ? Colors.white
                      : Theme.of(context).colorScheme.primary,
                ),
                if (widget.showHints) ...[
                  SizedBox(height: 10),
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      list[randomIndex % list.length],
                      style: TextStyle(
                        color: widget.colorful
                            ? Colors.white
                            : Theme.of(context).colorScheme.onBackground,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
