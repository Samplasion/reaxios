import 'package:flutter/material.dart';
import 'package:reaxios/components/Utilities/NotificationBadge.dart';
import 'package:styled_widget/styled_widget.dart';

class CardListItem extends StatefulWidget {
  CardListItem({
    required this.leading,
    required this.title,
    required this.subtitle,
    this.details,
    this.onClick,
    this.radius = 15,
    this.elevation = 8,
  });

  final Widget leading;
  final String title;
  final Widget subtitle;
  final Widget? details;
  final void Function()? onClick;
  final double radius;
  final double elevation;

  @override
  _CardListItemState createState() => _CardListItemState();
}

class _CardListItemState extends State<CardListItem> {
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
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    ).padding(bottom: 5);

    final Widget description = widget.subtitle;

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
          description.padding(
              bottom: widget.details == null ||
                      (description is Container && description.child == null)
                  ? 0
                  : 8),
          if (widget.details != null) widget.details!,
        ].toColumn(crossAxisAlignment: CrossAxisAlignment.start),
        enabled: true,
        dense: true,
        mouseCursor: widget.onClick == null ? null : SystemMouseCursors.click,
        // onTap: () {},
      ).padding(all: 8),
    );
  }
}
