import 'package:flutter/material.dart';
import 'package:reaxios/components/Utilities/NotificationBadge.dart';

class CardListItem extends StatefulWidget {
  CardListItem({
    required this.leading,
    required this.title,
    required this.subtitle,
    this.details,
    this.onClick,
    this.onLongPress,
    this.radius = 15,
    this.elevation = 8,
    this.titleStyle,
  });

  final Widget leading;
  final String title;
  final Widget subtitle;
  final Widget? details;
  final void Function()? onClick;
  final void Function()? onLongPress;
  final double radius;
  final double elevation;
  final TextStyle? titleStyle;

  @override
  _CardListItemState createState() => _CardListItemState();
}

class _CardListItemState extends State<CardListItem> {
  bool pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Widget title = Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Text(
        widget.title,
        style: TextStyle(
          fontFamily: theme.textTheme.titleLarge!.fontFamily,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ).merge(widget.titleStyle),
      ),
    );

    final Widget description = widget.subtitle;

    Widget leading = widget.leading;
    if (leading is! NotificationBadge) {
      leading = NotificationBadge(
        child: widget.leading,
        showBadge: false,
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Card(
        margin: EdgeInsets.zero,
        surfaceTintColor: theme.cardTheme.surfaceTintColor,
        shadowColor: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(13),
          onTap: widget.onClick,
          onLongPress: widget.onLongPress,
          mouseCursor: widget.onClick == null ? null : SystemMouseCursors.click,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: ListTile(
              leading: Container(
                child: leading,
                width: 50,
                height: 50,
              ),
              title: title,
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: widget.details == null ||
                              (description is Container &&
                                  description.child == null)
                          ? 0
                          : 8,
                    ),
                    child: description,
                  ),
                  if (widget.details != null) widget.details!,
                ],
              ),
              enabled: true,
              dense: true,
              mouseCursor:
                  widget.onClick == null ? null : SystemMouseCursors.click,
              // onTap: () {},
            ),
          ),
        ),
      ),
    );
  }
}
