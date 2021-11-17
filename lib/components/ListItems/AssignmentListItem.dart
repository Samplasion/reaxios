import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:reaxios/api/entities/Assignment/Assignment.dart';
import 'package:reaxios/api/utils/utils.dart';
import 'package:reaxios/components/Utilities/CardListItem.dart';
import 'package:reaxios/utils.dart';
import 'package:url_launcher/url_launcher.dart';
import "package:styled_widget/styled_widget.dart";

class AssignmentListItem extends StatelessWidget {
  const AssignmentListItem({Key? key, required this.assignment, this.onClick})
      : super(key: key);

  final Assignment assignment;
  final void Function()? onClick;

  @override
  Widget build(BuildContext context) {
    final bg = assignment.date > DateTime.now()
        ? Theme.of(context).accentColor
        : Colors.grey[700]!;
    return CardListItem(
      leading: CircleAvatar(
        child:
            Icon(Utils.getBestIconForSubject(assignment.subject, Icons.book)),
        backgroundColor: bg,
        foregroundColor: getContrastText(bg),
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
                  context.showSnackbar(context.locale.main.failedLinkOpen);
                }
              },
            ),
      details: Text(context.dateToString(assignment.date)),
      // isThreeLine: true,
      onClick: onClick,
    ).padding(horizontal: 16);
  }
}
