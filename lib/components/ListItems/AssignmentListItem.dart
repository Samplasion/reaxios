import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:axios_api/entities/Assignment/Assignment.dart';
import 'package:reaxios/components/LowLevel/GradientCircleAvatar.dart';
import 'package:reaxios/components/Utilities/CardListItem.dart';
import 'package:reaxios/utils/utils.dart';
import 'package:url_launcher/url_launcher.dart';
import "package:styled_widget/styled_widget.dart";

class AssignmentListItem extends StatelessWidget {
  const AssignmentListItem({Key? key, required this.assignment, this.onClick})
      : super(key: key);

  final Assignment assignment;
  final void Function()? onClick;

  @override
  Widget build(BuildContext context) {
    final bg = assignment.date.isAfter(DateTime.now()) ||
            assignment.date.isSameDay(DateTime.now())
        ? Theme.of(context).colorScheme.secondary
        : Colors.grey[700]!;
    return CardListItem(
      leading: GradientCircleAvatar(
        child:
            Icon(Utils.getBestIconForSubject(assignment.subject, Icons.book)),
        color: bg,
      ),
      title: (assignment.subject),
      subtitle: assignment.assignment.trim().isEmpty
          ? Container()
          : SelectableLinkify(
              text: assignment.assignment.trim(),
              style:
                  TextStyle(color: Theme.of(context).textTheme.caption?.color),
              onOpen: (link) async {
                if (await canLaunch(link.url)) {
                  await launch(link.url);
                } else {
                  context.showSnackbar(
                      context.loc.translate("main.failedLinkOpen"));
                }
              },
            ),
      details: Text(context.dateToString(assignment.date)),
      // isThreeLine: true,
      onClick: onClick,
    ).padding(horizontal: 16);
  }
}
