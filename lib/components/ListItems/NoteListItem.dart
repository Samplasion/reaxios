import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:reaxios/api/Axios.dart';
import 'package:reaxios/api/entities/Note/Note.dart';
import 'package:reaxios/api/enums/NoteKind.dart';
import 'package:reaxios/api/utils/utils.dart';
import 'package:reaxios/components/LowLevel/GradientCircleAvatar.dart';
// import 'package:reaxios/components/NoteView.dart';
import 'package:reaxios/components/Utilities/CardListItem.dart';
import 'package:reaxios/system/Store.dart';
import 'package:reaxios/utils.dart';
import 'package:url_launcher/url_launcher.dart';
import "package:styled_widget/styled_widget.dart";

class NoteListItem extends StatelessWidget {
  NoteListItem(
      {Key? key,
      required this.note,
      required this.session,
      this.onClick = true})
      : super(key: key);

  final Note note;
  final bool onClick;
  final Axios session;

  final Map<NoteKind, Color> colors = {
    NoteKind.Notice: Colors.purple[400]!,
    NoteKind.Note: Colors.lightGreen[500]!,
  };
  final Map<NoteKind, IconData> icons = {
    NoteKind.Notice: Icons.mail,
    NoteKind.Note: Icons.people,
  };

  @override
  Widget build(BuildContext context) {
    final bg = colors[note.kind]!;
    final leading = GradientCircleAvatar(
      child: Icon(icons[note.kind]!),
      color: bg,
    );

    final tile = CardListItem(
      leading: leading,
      title: note.teacher,
      subtitle: SelectableLinkify(
        text: note.content.replaceAll("<i>Comunicazione: </i>", "").trim(),
        style: TextStyle(color: Theme.of(context).textTheme.caption?.color),
        onOpen: (link) async {
          if (await canLaunch(link.url)) {
            await launch(link.url);
          } else {
            context.showSnackbar(context.locale.main.failedLinkOpen);
          }
        },
      ),
      details: Text(context.dateToString(note.date)),
    );

    return tile;
  }
}
