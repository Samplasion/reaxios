import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:axios_api/client.dart';
import 'package:axios_api/entities/Note/Note.dart';
import 'package:axios_api/enums/NoteKind.dart';
import 'package:reaxios/components/LowLevel/GradientCircleAvatar.dart';
import 'package:reaxios/components/Utilities/CardListItem.dart';
import 'package:reaxios/utils/utils.dart';
import 'package:url_launcher/url_launcher_string.dart';

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
    final bg = context.harmonize(color: colors[note.kind]!);
    final leading = GradientCircleAvatar(
      child: Icon(icons[note.kind]!),
      color: bg,
    );

    final tile = CardListItem(
      leading: leading,
      title: note.teacher,
      subtitle: SelectableLinkify(
        text: note.cleanContent.trim(),
        style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color),
        onOpen: (link) async {
          if (await canLaunchUrlString(link.url)) {
            await launchUrlString(link.url);
          } else {
            context.showSnackbar(context.loc.translate("main.failedLinkOpen"));
          }
        },
      ),
      details: Text(context.dateToString(note.date)),
    );

    return tile;
  }
}
