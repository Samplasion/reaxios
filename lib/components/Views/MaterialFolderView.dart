// ignore_for_file: deprecated_member_use

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:reaxios/api/entities/Material/Material.dart';
import 'package:reaxios/api/utils/utils.dart';
import 'package:reaxios/components/Utilities/CardListItem.dart';
import 'package:reaxios/components/LowLevel/Empty.dart';
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
  RefreshController _refreshController =
      RefreshController(initialRefresh: true);

  List<MaterialData> _materials = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.folder.description),
      ),
      body: SmartRefresher(
        enablePullDown: true,
        enablePullUp: false,
        controller: _refreshController,
        onRefresh: _onRefresh,
        onLoading: _onLoading,
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
      child: CircleAvatar(
        foregroundColor: accent.contrastText,
        backgroundColor: accent,
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

    return CardListItem(
      leading: icon,
      title: title,
      subtitle: subtitle,
      details: Text(
          "$name – ${context.dateToString(material.date, includeTime: true)}"),
      onClick: () => _onClick(material),
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

  _onRefresh() async {
    try {
      await _loadData();
      _refreshController.refreshCompleted();
    } catch (e) {
      // print(e);
      if (e is Error) // print(e.stackTrace);
        _refreshController.refreshFailed();
    }
  }

  _onLoading() async {
    try {
      await _loadData();
      _refreshController.loadComplete();
    } catch (e) {
      // print(e);
      if (e is Error) // print(e.stackTrace);
        _refreshController.loadFailed();
    }
  }
}
