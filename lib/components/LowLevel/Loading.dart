import 'dart:math';

import 'package:flutter/material.dart' hide Gradient;
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:reaxios/components/LowLevel/Gradient.dart';
import 'package:reaxios/utils.dart';

class LoadingUI extends StatefulWidget {
  final bool colorful, showHints;

  LoadingUI({
    this.colorful = false,
    this.showHints = false,
    Key? key,
  }) : super(key: key);

  @override
  _LoadingUIState createState() => _LoadingUIState();
}

class _LoadingUIState extends State<LoadingUI> {
  int randomIndex = Random().nextInt(100);

  List<String> getDidYouKnow(BuildContext context) =>
      context.locale.main.didYouKnow.split("\n");

  @override
  Widget build(BuildContext context) {
    final list = getDidYouKnow(context);
    return Container(
      padding: EdgeInsets.all(16),
      child: Stack(
        children: [
          if (widget.colorful)
            Gradient(colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondary,
            ]),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SpinKitDualRing(
                color: widget.colorful
                    ? Colors.white
                    : Theme.of(context).colorScheme.primary,
              ),
              if (widget.showHints) ...[
                SizedBox(height: 10),
                Text(
                  list[randomIndex % list.length],
                  style: TextStyle(
                    color: widget.colorful
                        ? Colors.white
                        : Theme.of(context).colorScheme.onBackground,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
