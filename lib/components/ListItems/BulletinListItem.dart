import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:reaxios/api/Axios.dart';
import 'package:reaxios/api/entities/Bulletin/Bulletin.dart';
import 'package:reaxios/api/enums/BulletinKind.dart';
import 'package:reaxios/api/utils/utils.dart';
import 'package:reaxios/components/Views/BulletinView.dart';
import 'package:reaxios/components/Utilities/CardListItem.dart';
import 'package:reaxios/components/Utilities/NotificationBadge.dart';
import 'package:reaxios/system/Store.dart';
import 'package:reaxios/utils.dart';
import 'package:url_launcher/url_launcher.dart';
import "package:styled_widget/styled_widget.dart";

class BulletinListItem extends StatelessWidget {
  BulletinListItem({
    Key? key,
    required this.bulletin,
    required this.session,
    required this.store,
    this.reload,
    this.onClick = true,
  }) : super(key: key);

  final Bulletin bulletin;
  final bool onClick;
  final Axios session;
  final RegistroStore store;
  final void Function()? reload;

  final Map<BulletinKind, Color> colors = {
    BulletinKind.Principal: Colors.purple[400]!,
    BulletinKind.Secretary: Colors.orange[500]!,
    BulletinKind.BoardOfTeachers: Colors.yellow[500]!,
    BulletinKind.Teacher: Colors.teal[500]!,
    BulletinKind.Other: Colors.blue[400]!,
  };

  @override
  Widget build(BuildContext context) {
    final bg = colors[bulletin.kind]!; // Theme.of(context).accentColor;
    final downloadBg = Theme.of(context).primaryColor;
    final av = CircleAvatar(
      child: Icon(Icons.mail),
      backgroundColor: bg,
      foregroundColor: bg.contrastText,
    );
    final downloadIcon = [
      CircleAvatar(
        child: Container(),
        backgroundColor: Theme.of(context).cardColor,
        radius: 12,
      ),
      CircleAvatar(
        child: Icon(
          Icons.download,
          size: 13,
        ),
        backgroundColor: downloadBg,
        foregroundColor: downloadBg.contrastText,
        radius: 9,
      )
    ].toStack(alignment: Alignment.center);

    final leading = [
      NotificationBadge(child: Container(child: av), showBadge: !bulletin.read),
      if (bulletin.attachments.length > 0)
        Container(width: 22, height: 22, child: downloadIcon)
            .width(22)
            .height(22)
            .positioned(bottom: -2, right: -2),
    ].toStack();

    final tile = CardListItem(
      leading: leading,
      title: bulletin.humanReadableKind,
      subtitle: bulletin.desc.trim().isEmpty
          ? Container()
          : Linkify(
              text: bulletin.desc.trim(),
              style:
                  TextStyle(color: Theme.of(context).textTheme.caption?.color),
              onOpen: (link) async {
                if (await canLaunch(link.url)) {
                  await launch(link.url);
                } else {
                  context.showSnackbar('Impossibile aprire il link.');
                }
              },
            ),
      details: Text(dateToString(bulletin.date)),
      onClick: !onClick
          ? null
          : () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return BulletinView(
                  bulletin: bulletin,
                  axios: session,
                  store: store,
                  reload: reload,
                );
              }));
            },
    );

    return tile;
  }
}
