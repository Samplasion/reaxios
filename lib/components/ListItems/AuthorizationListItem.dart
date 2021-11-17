import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:reaxios/api/Axios.dart';
import 'package:reaxios/api/entities/Authorization/Authorization.dart';
import 'package:reaxios/api/utils/utils.dart';
import 'package:reaxios/components/Utilities/NotificationBadge.dart';
import 'package:reaxios/components/Views/AuthorizationView.dart';
// import 'package:reaxios/components/AuthorizationView.dart';
import 'package:reaxios/components/Utilities/CardListItem.dart';
import 'package:reaxios/format.dart';
import 'package:reaxios/utils.dart';
import 'package:url_launcher/url_launcher.dart';
import "package:styled_widget/styled_widget.dart";

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
      child: CircleAvatar(
        child: Icon(Icons.edit),
        backgroundColor: bg,
        foregroundColor: getContrastText(bg),
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
      details: Text("${context.dateToString(authorization.startDate)}" +
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
