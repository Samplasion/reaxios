import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:reaxios/api/Axios.dart';
import 'package:reaxios/api/entities/Authorization/Authorization.dart';
import 'package:reaxios/components/LowLevel/GradientCircleAvatar.dart';
import 'package:reaxios/components/Utilities/NotificationBadge.dart';
import 'package:reaxios/components/Views/AuthorizationView.dart';
import 'package:reaxios/components/Utilities/CardListItem.dart';
import 'package:reaxios/format.dart';
import 'package:reaxios/utils.dart';

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
    final bg = colors[authorization.rawKind] ??
        colors["Other"]!; // sTheme.of(context).accentColor;
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
            context.locale.authorizations.justifiedSubtitle
                .format([context.dateToString(authorization.authorizedDate)])
        : "";

    final concursText = authorization.concurs
        ? "\n" + context.locale.authorizations.calculated
        : "\n" + context.locale.authorizations.notCalculated;

    final lessonHour = authorization.lessonHour == null
        ? ""
        : " — " +
            context.locale.main.lessonHour
                .format([authorization.lessonHour.toString()]);

    final tile = CardListItem(
      leading: leading,
      title: context.locale.authorizations
          .getByKey("type${authorization.rawKind}"),
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
