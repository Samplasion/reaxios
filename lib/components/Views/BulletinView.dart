import 'package:flutter/material.dart';
import 'package:reaxios/api/Axios.dart';
import 'package:reaxios/api/entities/Bulletin/Bulletin.dart';
import 'package:reaxios/api/enums/BulletinAttachmentKind.dart';
import 'package:reaxios/components/ListItems/BulletinListItem.dart';
import 'package:reaxios/components/Utilities/CardListItem.dart';
import 'package:reaxios/components/Utilities/NotificationBadge.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:reaxios/main.dart';
import 'package:reaxios/system/Store.dart';
import 'package:reaxios/utils.dart';
import 'package:url_launcher/url_launcher.dart';

class BulletinView extends StatelessWidget {
  const BulletinView({
    Key? key,
    required this.bulletin,
    required this.axios,
    required this.store,
    this.reload,
  }) : super(key: key);

  final Bulletin bulletin;
  final Axios axios;
  final RegistroStore store;
  final void Function()? reload;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Comunicazione: ${bulletin.humanReadableKind}"),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            padding: EdgeInsets.all(16),
            constraints: BoxConstraints(maxWidth: kTabBreakpoint),
            child: Column(
              children: [
                Hero(
                  child: BulletinListItem(
                    bulletin: bulletin,
                    onClick: false,
                    session: axios,
                    store: store,
                  ),
                  tag: bulletin.toString(),
                ),
                ..._getAttachmentWidgets(context),
                ..._getAccessories(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _getAccessories(BuildContext context) {
    return [
      Divider(),
      if (!bulletin.read)
        ElevatedButton(
          onPressed: () {
            axios.markBulletinAsRead(bulletin).then((_) {
              store.fetchBulletins(axios, true);
              if (reload != null) reload!();
              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Comunicazione segnata come letta.")),
              );
            });
          },
          child: Text("Segna come letta"),
        ),
      if (bulletin.read) Text("Comunicazione già letta.")
    ];
  }

  List<Widget> _getAttachmentWidgets(BuildContext context) {
    if (bulletin.attachments.length == 0) return [];
    final bg = Theme.of(context).accentColor;
    return [
      ...bulletin.attachments
          .map(
            (e) => CardListItem(
              leading: NotificationBadge(
                showBadge: false,
                child: CircleAvatar(
                  child: Icon(e.kind == BulletinAttachmentKind.File
                      ? Icons.file_present_rounded
                      : Icons.web),
                  backgroundColor: bg,
                  foregroundColor: bg.contrastText,
                ),
              ),
              title: e.sourceName ?? e.desc ?? "",
              subtitle: Text(e.kind == BulletinAttachmentKind.File
                  ? "Scarica file"
                  : "Apri pagina"),
              onClick: () async {
                if (await canLaunch(e.url)) {
                  if (e.kind == BulletinAttachmentKind.File) {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text("Scarica file"),
                        content:
                            Text("Vuoi scaricare il file ${e.sourceName}?"),
                        actions: [
                          TextButton(
                            child: Text("Annulla"),
                            onPressed: () => Navigator.pop(context),
                          ),
                          TextButton(
                            child: Text("Scarica"),
                            onPressed: () {
                              Navigator.pop(context);
                              launch(e.url);
                            },
                          ),
                        ],
                      ),
                    );
                  } else {
                    await launch(e.url);
                  }
                } else {
                  if (e.kind == BulletinAttachmentKind.File) {
                    context.showSnackbar("Impossibile scaricare il file.");
                  } else {
                    context.showSnackbar("Impossibile aprire la pagina.");
                  }
                }
              },
            ),
          )
          .toList(),
    ];
  }
}
