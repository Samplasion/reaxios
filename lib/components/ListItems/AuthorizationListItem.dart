import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:axios_api/client.dart';
import 'package:axios_api/entities/Authorization/Authorization.dart';
import 'package:reaxios/components/LowLevel/GradientCircleAvatar.dart';
import 'package:reaxios/components/Utilities/NotificationBadge.dart';
import 'package:reaxios/components/Views/AuthorizationView.dart';
import 'package:reaxios/components/Utilities/CardListItem.dart';
import 'package:reaxios/utils/format.dart';
import 'package:reaxios/utils/utils.dart';

class AuthorizationListItem extends StatelessWidget {
  AuthorizationListItem({
    Key? key,
    required this.authorization,
    required this.session,
    this.onClick = true,
    this.rebuild,
  }) : super(key: key);

  final Authorization authorization;
  final bool onClick;
  final Axios session;
  final void Function()? rebuild;

  final Map<String, Color> colors = {
    "A": Colors.red[500]!,
    "R": Colors.orange[500]!,
    "U": Colors.yellow[500]!,
    "E": Colors.green[500]!,
    "Other": Colors.teal[500]!,
  };

  @override
  Widget build(BuildContext context) {
    final bg = context.harmonize(
        color: colors[authorization.rawKind] ??
            colors["Other"]!); // sTheme.of(context).accentColor;
    final leading = NotificationBadge(
      child: GradientCircleAvatar(
        child: Text(authorization.rawKind.characters.first),
        color: bg,
      ),
      showBadge: !authorization.justified,
      rightOffset: 5,
    );

    final justifiedText = authorization.justified &&
            authorization.authorizedDate.millisecondsSinceEpoch >
                DateTime(2000).millisecondsSinceEpoch
        ? "\n" +
            context.loc.translate(
              "authorizations.justifiedSubtitle",
              {"0": context.dateToString(authorization.authorizedDate)},
            )
        : "";

    final concursText = authorization.concurs
        ? "\n" + context.loc.translate("authorizations.calculated")
        : "\n" + context.loc.translate("authorizations.notCalculated");

    final lessonHour = authorization.lessonHour == null
        ? ""
        : " — " +
            context.loc.translate(
              "main.lessonHour",
              {"0": authorization.lessonHour.toString()},
            );

    final tile = CardListItem(
      leading: leading,
      title:
          context.loc.translate("authorizations.type${authorization.rawKind}"),
      subtitle: MarkdownBody(
        data: "**${authorization.insertedBy}**\n$concursText  $justifiedText",
        styleSheet: MarkdownStyleSheet(
          p: TextStyle(color: Theme.of(context).textTheme.caption!.color),
        ),
      ),
      details: Text(
          "${context.dateToString(authorization.startDate)}$lessonHour" +
              (!authorization.endDate.isSameDay(authorization.startDate)
                  ? " - ${context.dateToString(authorization.endDate)}"
                  : "")),
      onClick: !onClick
          ? null
          : () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return AuthorizationView(
                  authorization: authorization,
                  axios: session,
                  reload: rebuild,
                );
              }));
            },
    );

    return tile;
  }
}
