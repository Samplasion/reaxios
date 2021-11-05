// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:reaxios/api/entities/Material/Material.dart';
import 'package:reaxios/components/Utilities/CardListItem.dart';
import 'package:reaxios/components/LowLevel/Empty.dart';
import 'package:reaxios/components/Utilities/NotificationBadge.dart';
import 'package:reaxios/components/Views/MaterialFolderView.dart';
import 'package:reaxios/utils.dart';
import 'package:styled_widget/styled_widget.dart';

class MaterialTeacherView extends StatelessWidget {
  final MaterialTeacherData teacher;

  MaterialTeacherView(this.teacher);

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).accentColor;
    return Scaffold(
      appBar: AppBar(
        title: Text(teacher.name),
      ),
      body: _buildBody(context, accent),
    );
  }

  Widget _buildBody(BuildContext context, Color accent) {
    if (teacher.folders.isEmpty) {
      return Center(
        child: EmptyUI(
          text: 'Nessun materiale',
          subtitle: 'Non ci sono materiali per questo docente',
          icon: Icons.folder,
        ),
      );
    }

    return ListView.builder(
      itemCount: teacher.folders.length,
      itemBuilder: (context, index) {
        final text = teacher.folders[index].note;
        return CardListItem(
          leading: NotificationBadge(
            child: CircleAvatar(
              backgroundColor: accent,
              child: Icon(
                Icons.folder,
                color: accent.contrastText,
              ),
            ),
            showBadge: false,
          ),
          title: teacher.folders[index].description,
          subtitle: Text(
            text.isEmpty
                ? "Il docente non ha inserito alcuna descrizione per questa cartella."
                : text,
            style:
                text.isNotEmpty ? null : TextStyle(fontStyle: FontStyle.italic),
          ),
          onClick: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MaterialFolderView(
                  folder: teacher.folders[index],
                ),
              ),
            );
          },
        ).padding(
          horizontal: 16,
          top: index == 0 ? 8 : 0,
          bottom: index == teacher.folders.length - 1 ? 8 : 0,
        );
      },
    );
  }
}