import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';

import '../../utils.dart';

class BigCard extends StatefulWidget {
  final Widget? leading;
  final Widget body;
  final Color? color;
  final double elevation;
  final double radius;
  final Function()? onTap;
  final bool gradient;
  final double innerPadding;

  BigCard({
    this.leading,
    required this.body,
    this.color,
    this.elevation = 8.0,
    this.radius = 15.0,
    this.onTap,
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
    return _buildCard(context, child: _buildContent(context))
        .padding(vertical: 8);
  }

  Widget _buildCard(BuildContext context, {Widget? child}) {
    ThemeData theme = Theme.of(context);
    var item = Styled.widget(
      child: Theme(
        data: theme.copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
        ),
        child: (child ?? Container()).padding(all: widget.innerPadding),
      ),
    ).borderRadius(all: widget.radius);

    if (widget.onTap != null) {
      item = item.ripple().gestures(
            onTapChange: (tapStatus) => setState(() => pressed = tapStatus),
            onTap: widget.onTap,
          );
    }

    item = item.backgroundColor(widget.color ?? theme.cardTheme.color!,
        animate: true);

    return item
        .clipRRect(all: widget.radius) // clip ripple
        .borderRadius(all: widget.radius, animate: true)
        .constrained(minHeight: 80)
        .padding(vertical: 12) // margin
        .scale(all: pressed ? 0.98 : 1.0, animate: true)
        .animate(Duration(milliseconds: 150), Curves.easeOut);
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
