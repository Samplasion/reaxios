import 'dart:math';

import 'package:flutter/material.dart' hide Gradient;
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:reaxios/components/LowLevel/Gradient.dart';
import 'package:reaxios/utils.dart';

class LoadingUI extends StatelessWidget {
  final bool colorful, showHints;
  late int randomIndex;

  LoadingUI({
    this.colorful = false,
    this.showHints = false,
    Key? key,
  }) : super(key: key) {
    randomIndex = Random().nextInt(100);
  }

  List<String> getDidYouKnow(BuildContext context) =>
      context.locale.main.didYouKnow.split("\n");

  @override
  Widget build(BuildContext context) {
    final list = getDidYouKnow(context);
    return Container(
      child: Stack(
        children: [
          if (colorful)
            Gradient(colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondary,
            ]),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SpinKitDualRing(
                color: colorful
                    ? Colors.white
                    : Theme.of(context).colorScheme.primary,
              ),
              if (showHints) ...[
                SizedBox(height: 10),
                Text(
                  list[randomIndex % list.length],
                  style: TextStyle(
                    color: colorful
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
