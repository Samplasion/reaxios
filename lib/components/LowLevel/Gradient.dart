import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class Gradient extends StatefulWidget {
  final List<Color> colors;

  const Gradient({Key? key, required this.colors}) : super(key: key);

  @override
  _GradientState createState() => _GradientState();
}

class _GradientState extends State<Gradient> {
  List<Alignment> alignments = [
    Alignment.bottomLeft,
    Alignment.bottomRight,
    Alignment.topRight,
    Alignment.topLeft,
  ];
  int index = 0;
  late Color bottomColor = widget.colors.first;
  late Color topColor = widget.colors.first;
  late Alignment begin = alignments.last;
  late Alignment end = alignments.first;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      setState(() {
        topColor = widget.colors[1];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(seconds: 2),
      onEnd: () {
        setState(() {
          index = index + 1;
          // animate the color
          bottomColor = widget.colors[index % widget.colors.length];
          topColor = widget.colors[(index + 1) % widget.colors.length];

          // animate the alignment
          begin = alignments[index % alignments.length];
          end = alignments[(index + 2) % alignments.length];
        });
      },
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: begin,
          end: end,
          colors: [bottomColor, topColor],
        ),
      ),
    );
  }
}
