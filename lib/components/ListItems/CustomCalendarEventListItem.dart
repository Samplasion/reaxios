import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:reaxios/components/LowLevel/GradientCircleAvatar.dart';
import 'package:reaxios/components/Utilities/CardListItem.dart';
import 'package:reaxios/utils.dart';
import 'package:url_launcher/url_launcher.dart';
import "package:styled_widget/styled_widget.dart";

import '../../structs/calendar_event.dart';

class CustomCalendarEventListItem extends StatelessWidget {
  const CustomCalendarEventListItem({
    Key? key,
    required this.event,
    this.onClick,
    this.onLongPress,
    this.isSelected = false,
  }) : super(key: key);

  final CustomCalendarEvent event;
  final void Function()? onClick;
  final void Function()? onLongPress;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final bg = event.color;
    return CardListItem(
      leading: AnimatedCrossFade(
        firstChild: GradientCircleAvatar(
          child: Icon(Icons.calendar_today),
          color: bg,
        ),
        secondChild: GradientCircleAvatar(
          child: Icon(Icons.check),
          color: bg.contrastText,
          foregroundColor: bg,
        ),
        crossFadeState:
            isSelected ? CrossFadeState.showSecond : CrossFadeState.showFirst,
        duration: Duration(milliseconds: 300),
      ),
      title: (event.title),
      subtitle: event.description.trim().isEmpty
          ? Container()
          : SelectableLinkify(
              text: event.description.trim(),
              style:
                  TextStyle(color: Theme.of(context).textTheme.caption?.color),
              onOpen: (link) async {
                if (await canLaunch(link.url)) {
                  await launch(link.url);
                } else {
                  context.showSnackbar(context.locale.main.failedLinkOpen);
                }
              },
            ),
      details: Text(context.dateToString(event.date)),
      onClick: onClick,
      onLongPress: onLongPress,
    ).padding(horizontal: 16);
  }
}
