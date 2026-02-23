import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:axios_api/client.dart';
import 'package:axios_api/entities/Bulletin/Bulletin.dart';
import 'package:axios_api/enums/BulletinAttachmentKind.dart';
import 'package:reaxios/components/ListItems/BulletinListItem.dart';
import 'package:reaxios/components/LowLevel/GradientCircleAvatar.dart';
import 'package:reaxios/components/Utilities/CardListItem.dart';
import 'package:reaxios/components/Utilities/MaxWidthContainer.dart';
import 'package:reaxios/components/Utilities/NotificationBadge.dart';
import 'package:reaxios/cubit/app_cubit.dart';
import 'package:reaxios/utils/utils.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../LowLevel/m3/divider.dart';

class BulletinView extends StatelessWidget {
  const BulletinView({
    Key? key,
    required this.bulletin,
    required this.axios,
    this.reload,
  }) : super(key: key);

  final Bulletin bulletin;
  final Axios axios;
  final void Function()? reload;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.loc.translate("bulletins.title", {
            "0": context.loc
                .translate("bulletins.type${describeEnum(bulletin.kind)}"),
          }),
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
      M3Divider(),
      if (!bulletin.read)
        ElevatedButton(
          onPressed: () {
            final cubit = context.read<AppCubit>();
            axios.markBulletinAsRead(bulletin).then((_) {
              cubit.loadBulletins(force: true);
              if (reload != null) reload!();
              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(
                        context.loc.translate("bulletins.markedSuccessfully"))),
              );
            }).catchError((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(context.loc.translate("bulletins.markedError")),
                ),
              );
            });
          },
          child: Text(context.loc.translate("bulletins.markAsRead")),
        ),
      if (bulletin.read) Text(context.loc.translate("bulletins.alreadyRead")),
      if (kDebugMode) ...[
        M3Divider(),
        ElevatedButton(
          child: Text("[DEBUG] Print JSON"),
          onPressed: () {
            Logger.d(jsonEncode(bulletin.toJson()));
          },
        ),
      ]
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
                  ? context.loc.translate("bulletins.download")
                  : context.loc.translate("bulletins.openLink")),
              onClick: () async {
                if (await canLaunchUrlString(e.url)) {
                  if (e.kind == BulletinAttachmentKind.File) {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title:
                            Text(context.loc.translate("bulletins.download")),
                        content: Text(
                          context.loc.translate("bulletins.downloadBody",
                              {"0": e.sourceName.toString()}),
                        ),
                        actions: [
                          TextButton(
                            child:
                                Text(context.materialLocale.cancelButtonLabel),
                            onPressed: () => Navigator.pop(context),
                          ),
                          TextButton(
                            child: Text(context.loc
                                .translate("main.downloadButtonLabel")),
                            onPressed: () {
                              Navigator.pop(context);
                              launchUrlString(e.url);
                            },
                          ),
                        ],
                      ),
                    );
                  } else {
                    await launchUrlString(e.url);
                  }
                } else {
                  if (e.kind == BulletinAttachmentKind.File) {
                    context.showSnackbar(
                        context.loc.translate("main.failedFileDownload"));
                  } else {
                    context.showSnackbar(
                        context.loc.translate("main.failedLinkOpen"));
                  }
                }
              },
            ),
          )
          .toList(),
    ];
  }
}
