import 'package:flutter/material.dart';

class RestartWidget extends StatefulWidget {
  RestartWidget({Key? key, required this.child}) : super(key: key);

  Widget child;

  static _RestartWidgetState? of(BuildContext context) =>
      context.findAncestorStateOfType<_RestartWidgetState>();

  @override
  _RestartWidgetState createState() => _RestartWidgetState();
}

class _RestartWidgetState extends State<RestartWidget> {
  Key key = UniqueKey();

  void restart() {
    setState(() {
      key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(child: widget.child, key: key);
  }
}
