import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reaxios/api/Axios.dart';
import 'package:reaxios/api/entities/Note/Note.dart';
import 'package:reaxios/api/enums/NoteKind.dart';
import 'package:reaxios/components/LowLevel/Empty.dart';
import 'package:reaxios/components/LowLevel/Loading.dart';
import 'package:reaxios/components/ListItems/NoteListItem.dart';
import 'package:reaxios/system/Store.dart';
import 'package:sticky_headers/sticky_headers.dart';
import "package:styled_widget/styled_widget.dart";

class NotesPane extends StatefulWidget {
  NotesPane({
    Key? key,
    required this.session,
  }) : super(key: key);

  final Axios session;

  @override
  _NotesPaneState createState() => _NotesPaneState();
}

class _NotesPaneState extends State<NotesPane> {
  final ScrollController controller = ScrollController();

  Map<String, List<Note>> splitNotes(List<Note> notes) {
    return notes.fold(new Map(), (map, note) {
      final date = note.period;
      if (!map.containsKey(date))
        map[date] = [note];
      else
        map[date]!.add(note);

      return map;
    });
  }

  @override
  Widget build(BuildContext context) {
    RegistroStore store = Provider.of<RegistroStore>(context);
    return FutureBuilder<List<Note>>(
      future: store.notes ?? Future.value([]),
      initialData: [],
      builder: (BuildContext context, snapshot) {
        if (snapshot.hasError) return Text("${snapshot.error}");
        if (snapshot.hasData && snapshot.data!.isNotEmpty)
          return buildOk(context, snapshot.data!.reversed.toList());

        return LoadingUI();
      },
    );
  }

  Widget buildOk(BuildContext context, List<Note> notes) {
    notes = notes.where((n) => n.kind == NoteKind.Note).toList();
    final map = splitNotes(notes);
    final entries = map.entries.toList();

    if (notes.isEmpty) {
      return EmptyUI(
        icon: Icons.mark_as_unread,
        text: "Non hai comunicazioni.",
      );
    }

    return Container(
      child: ListView.separated(
        shrinkWrap: true,
        separatorBuilder: (_a, _b) => Divider(),
        controller: controller,
        itemBuilder: (context, i) {
          return StickyHeader(
            header: Container(
              height: 50.0,
              color: Theme.of(context).canvasColor,
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              alignment: Alignment.centerLeft,
              child: Text(
                entries[i].key,
                style: Theme.of(context).textTheme.caption,
              ),
            ),
            content: Padding(
              padding: i == entries.length - 1
                  ? EdgeInsets.only(bottom: 16)
                  : EdgeInsets.zero,
              child: ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, i1) {
                  final e = entries[i].value[i1];
                  return NoteListItem(note: e, session: widget.session);
                },
                itemCount: entries[i].value.length,
                shrinkWrap: true,
              ).paddingDirectional(horizontal: 16),
            ),
          );
        },
        itemCount: entries.length,
      ),
    );
  }
}
