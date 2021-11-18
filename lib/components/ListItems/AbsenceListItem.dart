import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:reaxios/api/Axios.dart';
import 'package:reaxios/api/entities/Absence/Absence.dart';
import 'package:reaxios/api/utils/utils.dart';
import 'package:reaxios/components/LowLevel/GradientCircleAvatar.dart';
import 'package:reaxios/components/Views/AbsenceView.dart';
import 'package:reaxios/components/Utilities/CardListItem.dart';
import 'package:reaxios/components/Utilities/NotificationBadge.dart';
import 'package:reaxios/format.dart';
import 'package:reaxios/utils.dart';
import "package:styled_widget/styled_widget.dart";

class AbsenceListItem extends StatelessWidget {
  AbsenceListItem(
      {Key? key,
      required this.absence,
      required this.session,
      this.onClick = true})
      : super(key: key);

  final Absence absence;
  final bool onClick;
  final Axios session;

  final Map<String, Color> colors = {
    "Assenze": Colors.red[500]!,
    "Ritardi": Colors.orange[500]!,
    "Uscite": Colors.yellow[500]!,
    "Other": Colors.teal[500]!,
    // AbsenceKind.Other: Colors.blue[400]!,
  };

  @override
  Widget build(BuildContext context) {
    final bg = colors[absence.kind] ?? colors["Other"]!;
    final av = GradientCircleAvatar(
      child: Icon(Icons.no_accounts),
      color: bg,
    );

    final leading =
        NotificationBadge(child: av, showBadge: !absence.isJustified).parent(
            ({Widget? child}) => Container(child: child).width(50).height(50));

    final justifiedText = absence.isJustified
        ? context.locale.absences.justifiedSubtitle.format([
            context.dateToString(absence.dateJustified),
            absence.kindJustified,
          ])
        : null;

    final showSubtitle = absence.kindJustified.isNotEmpty ||
        justifiedText != null && justifiedText.isNotEmpty;

    final tile = CardListItem(
      leading: leading,
      title: context.locale.absences.getByKey("type${absence.kind}"),
      subtitle: showSubtitle
          ? MarkdownBody(
              data: justifiedText!,
              styleSheet: MarkdownStyleSheet(
                p: TextStyle(color: Theme.of(context).textTheme.caption!.color),
              ),
            )
          : Container(),
      details: Text(context.dateToString(absence.date)),
      onClick: !onClick
          ? null
          : () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return AbsenceView(
                  absence: absence,
                  axios: session,
                );
              }));
            },
    );

    return tile;
  }
}
