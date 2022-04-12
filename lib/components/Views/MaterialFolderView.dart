// ignore_for_file: deprecated_member_use

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:reaxios/api/entities/Material/Material.dart';
import 'package:reaxios/components/LowLevel/GradientAppBar.dart';
import 'package:reaxios/components/LowLevel/GradientCircleAvatar.dart';
import 'package:reaxios/components/Utilities/CardListItem.dart';
import 'package:reaxios/components/LowLevel/Empty.dart';
import 'package:reaxios/components/Utilities/MaxWidthContainer.dart';
import 'package:reaxios/components/Utilities/NotificationBadge.dart';
import 'package:reaxios/format.dart';
import 'package:reaxios/utils.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class MaterialFolderView extends StatefulWidget {
  MaterialFolderView({Key? key, required this.folder}) : super(key: key);

  final MaterialFolderData folder;

  @override
  _MaterialFolderViewState createState() => _MaterialFolderViewState();
}

class _MaterialFolderViewState extends State<MaterialFolderView> {
  List<MaterialData> _materials = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        title: Text(widget.folder.description),
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: ListView.builder(
          itemBuilder: (context, index) {
            if (index >= _materials.length)
              return EmptyUI(
                icon: Icons.folder,
                text: context.locale.teachingMaterials.emptyFolder,
              );
            return _buildCard(_materials[index], index);
          },
          itemCount: max(_materials.length, 1),
        ),
      ),
    );
  }

  Widget _buildCard(MaterialData material, int index) {
    final accent = Theme.of(context).accentColor;
    final icon = NotificationBadge(
      child: GradientCircleAvatar(
        color: accent,
        child: Icon(material.isLink ? Icons.link : Icons.file_present_rounded),
      ),
      showBadge: false,
    );

    final title = material.description;
    final subtitle = material.text.isEmpty
        ? Text(
            context.locale.teachingMaterials.noMaterialDescription,
            style: TextStyle(fontStyle: FontStyle.italic),
          )
        : Text(material.text);
    final name = material.isLink
        ? Uri.tryParse(material.url)?.host.replaceFirst("://www.", "://") ??
            context.locale.teachingMaterials.noHost
        : material.fileName;

    return Center(
      child: MaxWidthContainer(
        child: CardListItem(
          leading: icon,
          title: title,
          subtitle: subtitle,
          details: Text(
              "$name – ${context.dateToString(material.date, includeTime: true)}"),
          onClick: () => _onClick(material),
        ),
      ),
    ).padding(
      horizontal: 16,
      top: index == 0 ? 8 : 0,
      bottom: index == _materials.length - 1 ? 8 : 0,
    );
  }

  _onClick(MaterialData material) async {
    if (material.isLink) {
      if (await canLaunch(material.url)) {
        launch(material.url);
      } else {
        context.showSnackbar(context.locale.main.failedLinkOpen);
      }
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(context.locale.teachingMaterials.downloadAlertTitle),
          content: Text(context.locale.teachingMaterials.downloadAlertBody
              .format([material.fileName])),
          actions: <Widget>[
            TextButton(
              child: Text(context.materialLocale.cancelButtonLabel),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text(context.locale.main.downloadButtonLabel),
              onPressed: () async {
                Navigator.of(context).pop();
                if (await canLaunch(material.fileUrl)) {
                  launch(material.fileUrl);
                } else {
                  context.showSnackbar(context.locale.main.failedFileDownload);
                }
              },
            ),
          ],
        ),
      );
    }
  }

  _loadData() async {
    _materials = await widget.folder.getMaterials();
    if (mounted) setState(() {});
  }

  Future<void> _onRefresh() async {
    await _loadData();
  }
}
