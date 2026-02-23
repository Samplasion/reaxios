import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:axios_api/client.dart';
import 'package:axios_api/entities/Note/Note.dart';
import 'package:axios_api/enums/NoteKind.dart';
import 'package:reaxios/components/LowLevel/Empty.dart';
import 'package:reaxios/components/LowLevel/Loading.dart';
import 'package:reaxios/components/ListItems/NoteListItem.dart';
import 'package:reaxios/components/Utilities/MaxWidthContainer.dart';
import 'package:reaxios/cubit/app_cubit.dart';
import 'package:reaxios/utils/utils.dart';
import 'package:sticky_headers/sticky_headers.dart';
import "package:styled_widget/styled_widget.dart";

import '../../components/LowLevel/m3/divider.dart';

class NotesPane extends StatefulWidget {
  NotesPane({
    Key? key,
    required this.session,
    required this.kind,
  }) : super(key: key);

  final Axios session;
  final NoteKind kind;

  @override
  _NotesPaneState createState() => _NotesPaneState();
}

class _NotesPaneState extends State<NotesPane> {
  final ScrollController controller = ScrollController();

  Future<void> _refresh() async {
    await context.read<AppCubit>().loadNotes(force: true);
  }

  Map<String, List<Note>> splitNotices(List<Note> notices) {
    return notices.fold(new Map(), (map, note) {
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
    return BlocBuilder<AppCubit, AppState>(
      builder: (BuildContext context, state) {
        if (state.notes != null)
          return buildOk(context, state.notes!.reversed.toList());

        return LoadingUI();
      },
    );
  }

  Widget buildOk(BuildContext context, List<Note> rawNotices) {
    final notices = rawNotices.where((n) => n.kind == widget.kind).toList();
    final map = splitNotices(notices);
    final entries = map.entries.toList();

    if (notices.isEmpty) {
      return EmptyUI(
        icon: Icons.perm_contact_calendar_outlined,
        text: context.loc.translate("disciplinaryNotices.empty"),
      );
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView.separated(
        shrinkWrap: true,
        separatorBuilder: (_a, _b) => M3Divider(),
        controller: controller,
        itemBuilder: (context, i) {
          return StickyHeader(
            header: Container(
              height: 50.0,
              color: Theme.of(context).canvasColor,
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              alignment: Alignment.centerLeft,
              child: Center(
                child: MaxWidthContainer(
                  child: Text(
                    entries[i].key,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
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
                  return Center(
                    child: MaxWidthContainer(
                      child: NoteListItem(note: e, session: widget.session),
                    ),
                  );
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
