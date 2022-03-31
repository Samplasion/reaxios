import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:reaxios/api/Axios.dart';
import 'package:reaxios/api/entities/Absence/Absence.dart';
import 'package:reaxios/api/entities/Student/Student.dart';
import 'package:reaxios/components/ListItems/AbsenceListItem.dart';
import 'package:reaxios/components/Utilities/Alert.dart';
import 'package:reaxios/components/LowLevel/Empty.dart';
import 'package:reaxios/components/LowLevel/Loading.dart';
import 'package:reaxios/components/Utilities/MaxWidthContainer.dart';
import 'package:reaxios/cubit/app_cubit.dart';
import 'package:reaxios/utils.dart';
import 'package:sticky_headers/sticky_headers.dart';
import "package:styled_widget/styled_widget.dart";

class AbsencesPane extends StatefulWidget {
  AbsencesPane({
    Key? key,
    required this.session,
  }) : super(key: key);

  final Axios session;

  @override
  _AbsencesPaneState createState() => _AbsencesPaneState();
}

class _AbsencesPaneState extends State<AbsencesPane> {
  final ScrollController controller = ScrollController();

  Map<String, List<Absence>> splitAbsences(List<Absence> absences) {
    return absences.fold(new Map(), (map, note) {
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
    if (widget.session.student?.securityBits[SecurityBits.hideAbsences] ==
        "1") {
      return EmptyUI(
        text: context.locale.absences.noPermission,
        icon: Icons.lock,
      ).padding(horizontal: 16);
    }

    return BlocBuilder<AppCubit, AppState>(
      builder: (BuildContext context, state) {
        if (state.absences != null) return buildOk(context, state.absences!);

        return LoadingUI();
      },
    );
  }

  Widget buildOk(BuildContext context, List<Absence> absences) {
    // absences = absences.where((n) => n.kind == NoteKind.Absence).toList();
    final map = splitAbsences(absences);
    final entries = map.entries.toList();

    if (absences.isEmpty) {
      return EmptyUI(
        icon: Icons.no_accounts_outlined,
        text: context.locale.absences.empty,
      );
    }

    // TODO: Convert to Scaffold + SliverList
    return Container(
      child: SingleChildScrollView(
        controller: controller,
        child: Column(
          children: [
            Center(
              child: MaxWidthContainer(
                child: Alert(
                  title: context.locale.absences.sectionAlertTitle,
                  color: Colors.orange,
                  text: MarkdownBody(
                      data: context.locale.absences.sectionAlertBody),
                ),
              ),
            ).padding(horizontal: 16, top: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              separatorBuilder: (_a, _b) => Divider(),
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
                          style: Theme.of(context).textTheme.caption,
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
                        return Hero(
                          tag: e.toString(),
                          child: Center(
                            child: MaxWidthContainer(
                              child: AbsenceListItem(
                                absence: e,
                                session: widget.session,
                              ),
                            ),
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
          ],
        ),
      ),
    );
  }
}
