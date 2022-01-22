import 'package:flutter/material.dart';
import 'package:reaxios/api/Axios.dart';
import 'package:reaxios/api/entities/Grade/Grade.dart';
import 'package:reaxios/components/LowLevel/GradientAppBar.dart';
import 'package:reaxios/components/LowLevel/GradientCircleAvatar.dart';
import 'package:reaxios/components/Utilities/CardListItem.dart';
import 'package:reaxios/components/ListItems/GradeListItem.dart';
import 'package:reaxios/components/Utilities/GradeText.dart';
import 'package:reaxios/components/Utilities/NotificationBadge.dart';
import 'package:reaxios/format.dart';
import 'package:reaxios/system/Store.dart';
import 'package:reaxios/utils.dart';

import '../../consts.dart';

class GradeView extends StatefulWidget {
  const GradeView({
    Key? key,
    required this.grade,
    required this.session,
    required this.store,
    this.reload,
  }) : super(key: key);

  final Grade grade;
  final Axios session;
  final RegistroStore store;
  final void Function()? reload;

  @override
  _GradeViewState createState() => _GradeViewState();
}

class _GradeViewState extends State<GradeView> {
  Grade get grade => widget.grade;
  Axios get session => widget.session;
  RegistroStore get store => widget.store;
  void Function()? get reload => widget.reload;

  Key key = UniqueKey();

  bool get gradeIsValid => grade.grade != 0 && grade.weight != 0;

  @override
  Widget build(BuildContext context) {
    final title = gradeIsValid
        ? context.locale.grades.gradeInSubject.format([
            grade.getPrettyGrade(context),
            grade.subject,
          ])
        : context.locale.grades.commentInSubject.format([grade.subject]);
    // print(grade.toJson());
    return Scaffold(
      appBar: GradientAppBar(
        title: Text(title),
      ),
      body: _buildBody(context),
    );
  }

  void refresh() => setState(() {
        key = UniqueKey();
      });

  Widget _buildBody(BuildContext context) {
    return KeyedSubtree(
      key: key,
      child: SingleChildScrollView(
        child: Center(
          child: Container(
            padding: EdgeInsets.all(16),
            constraints: BoxConstraints(maxWidth: kTabBreakpoint),
            child: Column(
              children: [
                Hero(
                  tag: grade.toString(),
                  child: GradeListItem(
                    grade: grade,
                    session: session,
                    rebuild: () {},
                  ),
                ),
                if (gradeIsValid) Divider(),
                if (gradeIsValid)
                  CardListItem(
                    leading: NotificationBadge(
                      child: GradientCircleAvatar(
                        color: Colors.indigo,
                        child: Icon(Icons.linear_scale),
                      ),
                      showBadge: false,
                    ),
                    title: context.locale.grades.value,
                    subtitle: Text.rich(GradeText(
                      context,
                      grade: grade.grade,
                      showNumericValue: true,
                    )),
                    details: Text(context.locale.grades.weight
                        .format([(grade.weight * 100).toInt()])),
                  ),
                Divider(),
                if (grade.seen)
                  CardListItem(
                    leading: NotificationBadge(
                      child: GradientCircleAvatar(
                        color: Colors.orange,
                        child: Text(grade.seenBy?[0] ?? ""),
                      ),
                      showBadge: false,
                    ),
                    title: context.locale.grades.seen,
                    subtitle: Text(grade.seenBy ?? ""),
                    details: Text(context.dateToString(
                      grade.seenOn,
                      includeTime: true,
                      includeSeconds: true,
                    )),
                  ),
                if (!grade.seen)
                  ElevatedButton(
                    onPressed: () {
                      session.markGradeAsRead(grade).then((_) {
                        store.fetchGrades(session, true);
                        if (reload != null) reload!();
                        // print(reload);
                        Navigator.pop(context);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(context.locale.grades.seenSnackbar),
                          ),
                        );
                      }).onError((_, __) {
                        context
                            .showSnackbar(context.locale.grades.errorSnackbar);
                      });
                    },
                    child: Text(context.locale.grades.markAsSeen),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
