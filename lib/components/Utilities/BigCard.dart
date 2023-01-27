import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';

import '../../utils.dart';

class BigCard extends StatefulWidget {
  final Widget? leading;
  final Widget body;
  final Color? color;
  final double elevation;
  final double radius;
  final bool gradient;
  final double innerPadding;

  BigCard({
    this.leading,
    required this.body,
    this.color,
    this.elevation = 8.0,
    this.radius = 15.0,
    this.gradient = false,
    this.innerPadding = 32,
  });

  @override
  _BigCardState createState() => _BigCardState();
}

class _BigCardState extends State<BigCard> {
  bool pressed = false;

  @override
  Widget build(BuildContext context) {
    return _buildCard(context, child: _buildContent(context));
  }

  Widget _buildCard(BuildContext context, {Widget? child}) {
    final theme = Theme.of(context);
    final cardTheme = theme.cardTheme;
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16),
      constraints: BoxConstraints(
        minHeight: 80,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.radius),
      ),
      clipBehavior: Clip.antiAlias,
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: EdgeInsets.all(widget.innerPadding),
          child: child,
        ),
        color: widget.color ?? Card().color,
        surfaceTintColor: widget.color == null ? null : Colors.transparent,
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (widget.leading != null) ...[
          widget.leading!,
          SizedBox(height: 16),
        ],
        widget.body,
      ],
    );
  }
}
