import 'package:flutter/material.dart';
import 'package:reaxios/components/Utilities/NotificationBadge.dart';
import 'package:styled_widget/styled_widget.dart';

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
    final theme = Theme.of(context);
    final bg = theme.cardColor;

    final settingsItem = ({Widget? child}) {
      var item = Styled.widget(
              child: Theme(
                  data: theme.copyWith(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                  ),
                  child: child ?? Container()))
          .alignment(Alignment.center)
          .borderRadius(all: widget.radius);

      if (widget.onClick != null) {
        item = item.ripple().gestures(
              onTapChange: (tapStatus) => setState(() => pressed = tapStatus),
              onTap: widget.onClick,
              onLongPress: widget.onLongPress,
            );
      }

      return item
          .backgroundColor(bg, animate: true)
          .clipRRect(all: widget.radius) // clip ripple
          .borderRadius(all: widget.radius, animate: true)
          .elevation(
            pressed ? 0 : widget.elevation,
            borderRadius: BorderRadius.circular(widget.radius),
            shadowColor: theme.shadowColor,
          ) // shadow borderRadius
          .constrained(minHeight: 80)
          .padding(vertical: 12) // margin
          .scale(all: pressed ? 0.95 : 1.0, animate: true)
          .animate(Duration(milliseconds: 150), Curves.easeOut);
    };

    final Widget icon = widget.leading;
    // .padding(all: 12)
    // .decorated(
    //   color: theme.accentColor,
    //   borderRadius: BorderRadius.circular(50),
    // )
    // .padding(left: 15, right: 10);

    final Widget title = Text(
      widget.title,
      style: TextStyle(
        fontFamily: Theme.of(context).textTheme.headline6!.fontFamily,
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ).merge(widget.titleStyle),
    ).padding(bottom: 5);

    final Text subtitle = widget.subtitle;

    Widget leading = icon;
    if (leading is! NotificationBadge) {
      leading = NotificationBadge(
        child: icon,
        showBadge: false,
      );
    }

    return settingsItem(
      child: ListTile(
        leading: leading.parent(
            ({Widget? child}) => Container(child: child).width(50).height(50)),
        title: title,
        subtitle: <Widget>[
          subtitle.copyWith(
            style: (subtitle.style ?? TextStyle()).merge(
              Theme.of(context).textTheme.labelLarge,
            ),
          ),
          widget.location.copyWith(
            style: (widget.location.style ?? TextStyle()).merge(
              Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontFamily:
                        Theme.of(context).textTheme.bodyText2?.fontFamily,
                  ),
            ),
          ),
          widget.date.copyWith(
            style: (widget.date.style ?? TextStyle()).merge(
              Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontFamily:
                        Theme.of(context).textTheme.bodyText2?.fontFamily,
                  ),
            ),
          ),
          SizedBox(height: 8),
          widget.description,
          if (widget.footer != null) ...[
            SizedBox(height: 8),
            widget.footer!,
          ]
        ].toColumn(crossAxisAlignment: CrossAxisAlignment.start),
        enabled: true,
        dense: true,
        mouseCursor: widget.onClick == null ? null : SystemMouseCursors.click,
        // onTap: () {},
      ).padding(all: 8),
    );
  }
}
