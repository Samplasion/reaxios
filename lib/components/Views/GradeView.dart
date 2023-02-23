import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:axios_api/Axios.dart';
import 'package:axios_api/entities/Grade/Grade.dart';
import 'package:reaxios/components/LowLevel/GradientCircleAvatar.dart';
import 'package:reaxios/components/Utilities/CardListItem.dart';
import 'package:reaxios/components/ListItems/GradeListItem.dart';
import 'package:reaxios/components/Utilities/GradeText.dart';
import 'package:reaxios/components/Utilities/NotificationBadge.dart';
import 'package:reaxios/utils/format.dart';
import 'package:reaxios/utils/utils.dart';

import '../../utils/consts.dart';
import '../../cubit/app_cubit.dart';
import '../LowLevel/m3/divider.dart';

class GradeView extends StatefulWidget {
  const GradeView({
    Key? key,
    required this.grade,
    required this.session,
    this.reload,
  }) : super(key: key);

  final Grade grade;
  final Axios session;
  final void Function()? reload;

  @override
  _GradeViewState createState() => _GradeViewState();
}

class _GradeViewState extends State<GradeView> {
  Grade get grade => widget.grade;
  Axios get session => widget.session;
  void Function()? get reload => widget.reload;

  Key key = UniqueKey();

  bool get gradeIsValid => grade.grade != 0 && grade.weight != 0;

  @override
  Widget build(BuildContext context) {
    final title = gradeIsValid
        ? context.loc.translate("grades.gradeInSubject").format([
            grade.getPrettyGrade(context),
            grade.subject,
          ])
        : context.loc
            .translate("grades.commentInSubject")
            .format([grade.subject]);
    // print(grade.toJson());
    return Scaffold(
      appBar: AppBar(
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
                if (gradeIsValid) ...[
                  M3Divider(),
                  CardListItem(
                    leading: NotificationBadge(
                      child: GradientCircleAvatar(
                        color: context.harmonize(color: Colors.indigo),
                        child: Icon(Icons.linear_scale),
                      ),
                      showBadge: false,
                    ),
                    title: context.loc.translate("grades.value"),
                    subtitle: Text.rich(GradeText(
                      context,
                      grade: grade.grade,
                      showNumericValue: true,
                    )),
                    details: Text(context.loc.translate("grades.weight",
                        {"0": (grade.weight * 100).toInt().toString()})),
                  ),
                ],
                M3Divider(),
                if (grade.seen)
                  CardListItem(
                    leading: NotificationBadge(
                      child: GradientCircleAvatar(
                        color: context.harmonize(color: Colors.orange),
                        child: Text(grade.seenBy?[0] ?? ""),
                      ),
                      showBadge: false,
                    ),
                    title: context.loc.translate("grades.seen"),
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
                        final cubit = context.read<AppCubit>();
                        cubit.loadGrades(force: true);
                        if (reload != null) reload!();
                        // print(reload);
                        Navigator.pop(context);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                context.loc.translate("grades.seenSnackbar")),
                          ),
                        );
                      }).onError((_, __) {
                        context.showSnackbar(
                            context.loc.translate("grades.errorSnackbar"));
                      });
                    },
                    child: Text(context.loc.translate("grades.markAsSeen")),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
