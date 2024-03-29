import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:axios_api/client.dart';
import 'package:axios_api/entities/Grade/Grade.dart';
import 'package:axios_api/entities/Structural/Structural.dart';
import 'package:axios_api/entities/Student/Student.dart';
import 'package:axios_api/utils/utils.dart' hide gradeAverage;
import 'package:reaxios/components/Charts/GradeTimeAverageChart.dart';
import 'package:reaxios/components/ListItems/GradeListItem.dart';
import 'package:reaxios/components/LowLevel/Empty.dart';
import 'package:reaxios/components/LowLevel/GradientCircleAvatar.dart';
import 'package:reaxios/components/LowLevel/MaybeMasterDetail.dart';
import 'package:reaxios/components/Utilities/BigCard.dart';
import 'package:reaxios/components/Utilities/CardListItem.dart';
import 'package:reaxios/components/Utilities/GradeAvatar.dart';
import 'package:reaxios/components/Utilities/GradeText.dart';
import 'package:reaxios/components/Utilities/MaxWidthContainer.dart';
import 'package:reaxios/components/LowLevel/ReloadableState.dart';
import 'package:reaxios/components/Utilities/NiceHeader.dart';
import 'package:reaxios/components/Utilities/NotificationBadge.dart';
import 'package:reaxios/components/Views/GradeSubjectView.dart';
import 'package:reaxios/cubit/app_cubit.dart';
import 'package:reaxios/utils/format.dart';
import 'package:reaxios/timetable/structures/Settings.dart';
import 'package:reaxios/utils/utils.dart';
import 'package:sticky_headers/sticky_headers.dart';
import 'package:styled_widget/styled_widget.dart';

class GradesPane extends StatefulWidget {
  GradesPane({
    Key? key,
    required this.session,
    required this.openMainDrawer,
    this.period,
  }) : super(key: key);

  final Axios session;
  final Function() openMainDrawer;
  final Period? period;

  @override
  _GradesPaneState createState() => _GradesPaneState();
}

class _Page {
  final String title;
  final Widget content;

  _Page(this.title, this.content);
}

class _GradesPaneState extends ReloadableState<GradesPane>
    with SingleTickerProviderStateMixin {
  String selectedSubject = "";

  ScrollController controller = ScrollController();
  ScrollController horizontalController = ScrollController();

  @override
  dispose() {
    controller.dispose();
    horizontalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.session.student?.securityBits[SecurityBits.hideGrades] == "1") {
      return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: Text(context.loc.translate("drawer.grades")),
          leading: MaybeMasterDetail.of(context)!.isShowingMaster
              ? null
              : Builder(builder: (context) {
                  return IconButton(
                    tooltip:
                        MaterialLocalizations.of(context).openAppDrawerTooltip,
                    onPressed: widget.openMainDrawer,
                    icon: Icon(Icons.menu),
                  );
                }),
        ),
        body: EmptyUI(
          text: context.loc.translate("main.noPermission"),
          icon: Icons.lock,
        ).padding(horizontal: 16),
      );
    }

    final cubit = context.watch<AppCubit>();

    return KeyedSubtree(
      key: key,
      child: AnimatedBuilder(
        animation: Provider.of<Settings>(context),
        builder: (BuildContext context, Widget? child) {
          return BlocBuilder(
            bloc: cubit,
            builder: (context, state) {
              return buildOk(context, cubit.currentPeriod, cubit.subjects);
            },
          );
        },
      ),
    );
  }

  @override
  rebuild() {
    super.rebuild();
    setState(() {});
  }

  Widget _reloadParent({required Widget child}) {
    return RefreshIndicator(
      onRefresh: () async {
        final cubit = context.read<AppCubit>();
        await cubit.loadGrades(force: true);
      },
      child: child,
    );
  }

  List<String> getPeriods(List<Grade> grades) {
    final periods =
        grades.map((grade) => grade.period).toSet().toList().reversed;
    return periods.toList();
  }

  List<_Page> getPages(
    BuildContext context,
    List<Grade> grades,
    Period? currentPeriod,
    List<String> subjects,
  ) =>
      [
        _Page(
          context.loc.translate("grades.subjects"),
          SafeArea(
            bottom: false,
            left: false,
            right: false,
            child: SingleChildScrollView(
              controller: controller,
              child: Column(
                children: [
                  MaxWidthContainer(child: _buildHeader(context, grades)),
                  MaxWidthContainer(
                    child: _buildSubjects(
                      context,
                      subjects,
                      grades,
                      currentPeriod?.desc,
                    ),
                  ).center().padding(bottom: 8),
                ],
              ),
            ).parent(_reloadParent),
          ),
        ),
        ...getPeriods(grades)
            .map((period) => _Page(
                  period,
                  SafeArea(
                    bottom: false,
                    left: false,
                    right: false,
                    child: SingleChildScrollView(
                      controller: controller,
                      child: Column(
                        children: [
                          MaxWidthContainer(
                              child: _buildHeader(context, grades, period)),
                          MaxWidthContainer(
                            child: _buildSubjects(
                              context,
                              subjects,
                              grades
                                  .where((grade) => grade.period == period)
                                  .toList(),
                              period,
                            ),
                          ).center().padding(bottom: 8),
                        ],
                      ),
                    ).parent(_reloadParent),
                  ),
                ))
            .toList(),
        _Page(
          context.loc.translate("grades.grades"),
          SafeArea(
            bottom: false,
            left: false,
            right: false,
            child: MaxWidthContainer(
              child: _buildSeparatedGrades(context, grades),
            ).center(),
          ),
        ),
      ];

  Widget buildOk(
      BuildContext context, Period? currentPeriod, List<String> subjects) {
    final cubit = context.watch<AppCubit>();
    final grades = cubit.grades.toList();
    final pages = getPages(context, grades, currentPeriod, subjects);

    if (grades.isEmpty) {
      return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: Text(context.loc.translate("drawer.grades")),
          leading: MaybeMasterDetail.of(context)!.isShowingMaster
              ? null
              : Builder(builder: (context) {
                  return IconButton(
                    tooltip:
                        MaterialLocalizations.of(context).openAppDrawerTooltip,
                    onPressed: widget.openMainDrawer,
                    icon: Icon(Icons.menu),
                  );
                }),
        ),
        body: EmptyUI(
          text: context.loc.translate("grades.noGrades"),
          icon: Icons.star_border,
        ).padding(horizontal: 16),
      );
    }

    return DefaultTabController(
      length: pages.length,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          notificationPredicate: (notification) => notification.depth == 1,
          title: Text(context.loc.translate("drawer.grades")),
          leading: MaybeMasterDetail.of(context)!.isShowingMaster
              ? null
              : Builder(builder: (context) {
                  return IconButton(
                    tooltip:
                        MaterialLocalizations.of(context).openAppDrawerTooltip,
                    onPressed: widget.openMainDrawer,
                    icon: Icon(Icons.menu),
                  );
                }),
          bottom: TabBar(
            tabs: pages.map((page) => Tab(text: page.title)).toList(),
            isScrollable: true,
          ),
        ),
        body: TabBarView(
          children: pages.map((p) => p.content).toList(),
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    List<Grade> grades, [
    String? period,
  ]) {
    final averageMode = Provider.of<Settings>(context).getAverageMode();
    if (period != null) {
      final periodGrades = grades.where((g) => g.period == period).toList();
      return BigCard(
        leading: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            NiceHeader(
              title: context.loc.translate("charts.average"),
              subtitle: period,
            ).padding(bottom: 8),
            GradeAvatar(
              grade: Grade.fakeFromDouble(
                gradeAverage(averageMode, periodGrades),
              ),
            )
          ],
        ),
        body: GradeTimeAverageChart(
          grades: periodGrades.toList(),
          dynamic: true,
        ),
      ).paddingDirectional(horizontal: 16);
    }

    return BigCard(
      leading: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          NiceHeader(
            title: context.loc.translate("charts.average"),
            subtitle: context.loc.translate("charts.scopeAllYear"),
          ).padding(bottom: 8),
          GradeAvatar(
            grade: Grade.fakeFromDouble(
              gradeAverage(averageMode, grades),
            ),
          ),
        ],
      ),
      body: GradeTimeAverageChart(
        grades: grades.toList(),
        dynamic: true,
      ),
    ).paddingDirectional(horizontal: 16);
  }

  Widget _buildGrades(BuildContext context, List<Grade> grades) {
    return ListView.builder(
      itemBuilder: (context, i) {
        if (i == 0 || i == grades.length) {
          return SizedBox(height: 8);
        }
        return Hero(
          child: GradeListItem(
            grade: grades[i - 1],
            rebuild: rebuild,
            session: widget.session,
            onClick: true,
          ),
          tag: grades[i - 1].toString(),
        ).padding(horizontal: 16);
      },
      itemCount: grades.length + 1,
    ).parent(_reloadParent);
  }

  Widget _buildSeparatedGrades(BuildContext context, List<Grade> grades) {
    final terms = grades.map((g) => g.period).toSet().toList();
    return ListView.builder(
      itemBuilder: (context, i) {
        final entries = grades.where((g) => g.period == terms[i]).toList();
        final average =
            gradeAverage(context.watch<Settings>().getAverageMode(), entries);
        return StickyHeader(
          header: Container(
            height: 50.0,
            color: Theme.of(context).canvasColor,
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            alignment: Alignment.centerLeft,
            child: Center(
              child: MaxWidthContainer(
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(text: terms[i]),
                      TextSpan(text: " ("),
                      GradeText(context, grade: average),
                      TextSpan(text: ")"),
                    ],
                    style: Theme.of(context).textTheme.caption,
                  ),
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
              itemBuilder: (context, j) {
                final e = entries[j];
                return Hero(
                  child: GradeListItem(
                    grade: e,
                    rebuild: rebuild,
                    session: widget.session,
                    onClick: true,
                  ),
                  tag: e.toString(),
                );
              },
              itemCount: entries.length,
              shrinkWrap: true,
            ).paddingDirectional(horizontal: 16),
          ),
        );
      },
      itemCount: terms.length,
    ).parent(_reloadParent);
  }

  Widget _buildSubjects(
    BuildContext context,
    List<String> subjects,
    List<Grade> grades,
    String? currentPeriod,
  ) {
    final averageMode = Provider.of<Settings>(context).getAverageMode();
    List<Widget> children = [];
    for (String subject in subjects
      ..sort((sa, sb) {
        final subjectGrades1 = grades
            .where((element) => element.subject == sa)
            .toList()
          ..sort((a, b) => b.date.compareTo(a.date));
        final average1 = gradeAverage(averageMode, subjectGrades1);
        final subjectGrades2 = grades
            .where((element) => element.subject == sb)
            .toList()
          ..sort((a, b) => b.date.compareTo(a.date));
        final average2 = gradeAverage(averageMode, subjectGrades2);

        if (isNaN(average1) && !isNaN(average2))
          return 1;
        else if (!isNaN(average1) && isNaN(average2))
          return -1;
        else if (isNaN(average1) && isNaN(average2))
          return sa.compareTo(sb);
        else
          return average2.compareTo(average1);
      })) {
      final subjectGrades = grades
          .where((element) => element.subject == subject)
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));
      final average = gradeAverage(averageMode, subjectGrades);
      final isEmpty = isNaN(average) || average == 0 || grades.isEmpty;
      final color = getGradeColor(context, isEmpty ? double.nan : average);
      children.add(
        CardListItem(
          leading: NotificationBadge(
            child: GradientCircleAvatar(
              child: Icon(Utils.getBestIconForSubject(subject, Icons.grade)),
              color: color,
            ),
            showBadge: subjectGrades.where((e) => !e.seen).isNotEmpty,
          ),
          title: subject,
          subtitle: RichText(
            text: TextSpan(
              style: Theme.of(context).textTheme.caption,
              children: [
                if (!isEmpty) ...[
                  TextSpan(
                      text: context.loc.translate("grades.mainPageAverage")),
                  GradeText(context, grade: average),
                ] else
                  TextSpan(text: context.loc.translate("grades.noGrades")),
              ],
            ),
          ),
          details: isEmpty
              ? null
              : Text(
                  context.loc.translate(
                    "grades.latestGrade",
                    {"0": context.dateToString(subjectGrades.first.date)},
                  ),
                ),
          onClick: isEmpty
              ? null
              : () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GradeSubjectView(
                        grades: subjectGrades,
                        subject: subject,
                        period: currentPeriod,
                        session: widget.session,
                      ),
                    ),
                  );
                },
        ).padding(horizontal: 16),
      );
    }
    return Column(
      children: children,
    );
  }
}
