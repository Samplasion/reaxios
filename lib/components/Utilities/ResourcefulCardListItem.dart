import 'package:flutter/material.dart';
import 'package:reaxios/components/Utilities/NotificationBadge.dart';

// # What
// ## Who
// ### Where
// ### When
// Description
class ResourcefulCardListItem extends StatefulWidget {
  ResourcefulCardListItem({
    required this.leading,
    required this.title,
    required this.subtitle,
    required this.location,
    required this.date,
    required this.description,
    this.footer,
    this.onClick,
    this.onLongPress,
    this.radius = 15,
    this.elevation = 8,
    this.titleStyle,
  });

  final Widget leading;
  final String title;
  final Text subtitle;
  final Text location;
  final Text date;
  final Widget description;
  final Widget? footer;
  final void Function()? onClick;
  final void Function()? onLongPress;
  final double radius;
  final double elevation;
  final TextStyle? titleStyle;

  @override
  _ResourcefulCardListItemState createState() =>
      _ResourcefulCardListItemState();
}

class _ResourcefulCardListItemState extends State<ResourcefulCardListItem> {
  bool pressed = false;

  @override
  Widget build(BuildContext context) {
    final Text subtitle = widget.subtitle;

    Widget leading = widget.leading;
    if (leading is! NotificationBadge) {
      leading = NotificationBadge(
        child: widget.leading,
        showBadge: false,
      );
    }

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Card(
        margin: EdgeInsets.zero,
        child: InkWell(
          onTap: widget.onClick,
          onLongPress: widget.onLongPress,
          mouseCursor: SystemMouseCursors.click,
          borderRadius: BorderRadius.circular(13),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: ListTile(
              leading: SizedBox(
                child: leading,
                width: 50,
                height: 50,
              ),
              title: Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Text(
                  widget.title,
                  style: TextStyle(
                    fontFamily:
                        Theme.of(context).textTheme.titleLarge!.fontFamily,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ).merge(widget.titleStyle),
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DefaultTextStyle.merge(
                    child: subtitle,
                    style: (subtitle.style ??
                            DefaultTextStyle.of(context).style)
                        .merge(Theme.of(context).textTheme.labelLarge)
                        .merge(
                          TextStyle(
                            color: Theme.of(context).textTheme.bodySmall!.color,
                          ),
                        ),
                  ),
                  DefaultTextStyle.merge(
                    child: widget.location,
                    style: (widget.location.style ??
                            DefaultTextStyle.of(context).style)
                        .merge(
                      Theme.of(context)
                          .textTheme
                          .labelMedium
                          ?.copyWith(
                            fontFamily: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.fontFamily,
                          )
                          .merge(
                            TextStyle(
                              color: Theme.of(context).textTheme.bodySmall!.color,
                            ),
                          ),
                    ),
                  ),
                  DefaultTextStyle.merge(
                    child: widget.date,
                    style: (widget.date.style ??
                            DefaultTextStyle.of(context).style)
                        .merge(
                      Theme.of(context)
                          .textTheme
                          .labelMedium
                          ?.copyWith(
                            fontFamily: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.fontFamily,
                          )
                          .merge(
                            TextStyle(
                              color: Theme.of(context).textTheme.bodySmall!.color,
                            ),
                          ),
                    ),
                  ),
                  SizedBox(height: 8),
                  widget.description,
                  if (widget.footer != null) ...[
                    SizedBox(height: 8),
                    widget.footer!,
                  ]
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
