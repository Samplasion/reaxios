import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:reaxios/api/Axios.dart';
import 'package:reaxios/api/entities/Bulletin/Bulletin.dart';
import 'package:reaxios/api/enums/BulletinAttachmentKind.dart';
import 'package:reaxios/components/ListItems/BulletinListItem.dart';
import 'package:reaxios/components/LowLevel/GradientAppBar.dart';
import 'package:reaxios/components/LowLevel/GradientCircleAvatar.dart';
import 'package:reaxios/components/Utilities/CardListItem.dart';
import 'package:reaxios/components/Utilities/MaxWidthContainer.dart';
import 'package:reaxios/components/Utilities/NotificationBadge.dart';
import 'package:reaxios/format.dart';
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
      appBar: GradientAppBar(
        title: Text(
          context.locale.bulletins.title.format([
            context.locale.bulletins
                .getByKey("type${describeEnum(bulletin.kind)}"),
          ]),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: MaxWidthContainer(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
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
                SnackBar(
                    content: Text(context.locale.bulletins.markedSuccessfully)),
              );
            }).catchError((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(context.locale.bulletins.markedError),
                ),
              );
            });
          },
          child: Text(context.locale.bulletins.markAsRead),
        ),
      if (bulletin.read) Text(context.locale.bulletins.alreadyRead),
    ];
  }

  List<Widget> _getAttachmentWidgets(BuildContext context) {
    if (bulletin.attachments.length == 0) return [];
    final bg = Theme.of(context).colorScheme.secondary;
    return [
      ...bulletin.attachments
          .map(
            (e) => CardListItem(
              leading: NotificationBadge(
                showBadge: false,
                child: GradientCircleAvatar(
                  child: Icon(e.kind == BulletinAttachmentKind.File
                      ? Icons.file_present_rounded
                      : Icons.web),
                  color: bg,
                ),
              ),
              title: () {
                String? title = e.sourceName;
                if (title == null || title.trim().isEmpty) title = e.desc;
                if (title == null || title.trim().isEmpty)
                  title = Uri.tryParse(e.url)?.host;
                if (title == null || title.trim().isEmpty) title = "";
                return title;
              }(),
              subtitle: Text(e.kind == BulletinAttachmentKind.File
                  ? context.locale.bulletins.download
                  : context.locale.bulletins.openLink),
              onClick: () async {
                print(jsonEncode(e.toJson()));
                if (await canLaunch(e.url)) {
                  if (e.kind == BulletinAttachmentKind.File) {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(context.locale.bulletins.download),
                        content: Text(context.locale.bulletins.downloadBody
                            .format([e.sourceName])),
                        actions: [
                          TextButton(
                            child:
                                Text(context.materialLocale.cancelButtonLabel),
                            onPressed: () => Navigator.pop(context),
                          ),
                          TextButton(
                            child:
                                Text(context.locale.main.downloadButtonLabel),
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
                    context
                        .showSnackbar(context.locale.main.failedFileDownload);
                  } else {
                    context.showSnackbar(context.locale.main.failedLinkOpen);
                  }
                }
              },
            ),
          )
          .toList(),
    ];
  }
}
