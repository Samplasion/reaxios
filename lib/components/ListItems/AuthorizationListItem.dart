import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:reaxios/api/Axios.dart';
import 'package:reaxios/api/entities/Authorization/Authorization.dart';
import 'package:reaxios/api/utils/utils.dart';
import 'package:reaxios/components/Utilities/NotificationBadge.dart';
import 'package:reaxios/components/Views/AuthorizationView.dart';
// import 'package:reaxios/components/AuthorizationView.dart';
import 'package:reaxios/components/Utilities/CardListItem.dart';
import 'package:url_launcher/url_launcher.dart';
import "package:styled_widget/styled_widget.dart";

class AuthorizationListItem extends StatelessWidget {
  AuthorizationListItem(
      {Key? key,
      required this.authorization,
      required this.session,
      this.onClick = true})
      : super(key: key);

  final Authorization authorization;
  final bool onClick;
  final Axios session;

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

    // final leading = [
    //   Container(child: av),
    //   if (!authorization.justified)
    //     Container(
    //       width: 10,
    //       height: 10,
    //       child: CircleAvatar(
    //         backgroundColor: Colors.red,
    //       ),
    //     ).positioned(top: 0, right: 7)
    // ].toStack();

    final justifiedText = authorization.justified
        ? "\nGiustificata il ${dateToString(authorization.authorizedDate)}."
        : "";

    final concursText = authorization.concurs
        ? "\nConcorre al calcolo."
        : "\nNon concorre al calcolo.";

    final tile = CardListItem(
      leading: leading,
      title: authorization.kind,
      subtitle: RichText(
        text: TextSpan(
          style: TextStyle(color: Theme.of(context).textTheme.caption?.color),
          children: [
            TextSpan(
              text: authorization.insertedBy,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: concursText),
            TextSpan(text: justifiedText),
          ],
        ),
      ),
      details: Text("${dateToString(authorization.startDate)}" +
          (authorization.endDate != authorization.startDate
              ? " - ${dateToString(authorization.endDate)}"
              : "")),
      onClick: !onClick
          ? null
          : () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return AuthorizationView(
                  authorization: authorization,
                  axios: session,
                );
              }));
            },
    );

    return tile;
  }
}
