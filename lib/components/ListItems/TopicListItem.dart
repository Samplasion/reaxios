import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:reaxios/api/entities/Topic/Topic.dart';
import 'package:reaxios/api/utils/utils.dart';
import 'package:reaxios/components/LowLevel/GradientCircleAvatar.dart';
import 'package:reaxios/components/Utilities/CardListItem.dart';
import 'package:reaxios/format.dart';
import 'package:reaxios/utils.dart';
import 'package:url_launcher/url_launcher.dart';
import "package:styled_widget/styled_widget.dart";

class TopicListItem extends StatelessWidget {
  const TopicListItem({Key? key, required this.topic, this.onClick})
      : super(key: key);

  final Topic topic;
  final void Function()? onClick;

  @override
  Widget build(BuildContext context) {
    final bg = topic.date.millisecondsSinceEpoch >
            DateTime.now().millisecondsSinceEpoch
        ? Theme.of(context).accentColor
        : Colors.grey[700]!;

    // \u00aa = ª
    final hr = topic.lessonHour.isEmpty
        ? ""
        : context.locale.main.lessonHour.format([topic.lessonHour]) + " - ";

    return CardListItem(
      leading: GradientCircleAvatar(
        child: Icon(
            Utils.getBestIconForSubject(topic.subject, Icons.calendar_today)),
        color: bg,
      ),
      title: (topic.subject),
      subtitle: SelectableLinkify(
        text: "$hr${topic.topic.trim()}".trim(),
        style: TextStyle(color: Theme.of(context).textTheme.caption?.color),
        onOpen: (link) async {
          if (await canLaunch(link.url)) {
            await launch(link.url);
          } else {
            context.showSnackbar(context.locale.main.failedLinkOpen);
          }
        },
      ),
      details: Text(context.dateToString(topic.date)),
      // isThreeLine: true,
      onClick: onClick,
    ).padding(horizontal: 16);
  }
}
