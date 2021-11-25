// ignore_for_file: deprecated_member_use

import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/src/provider.dart';
import 'package:reaxios/api/Axios.dart';
import 'package:reaxios/api/entities/Assignment/Assignment.dart';
import 'package:reaxios/api/entities/Grade/Grade.dart';
import 'package:reaxios/api/entities/Login/Login.dart';
import 'package:reaxios/api/entities/Structural/Structural.dart';
import 'package:reaxios/api/entities/Student/Student.dart';
import 'package:reaxios/api/entities/Topic/Topic.dart';
import 'package:reaxios/api/utils/utils.dart';
import 'package:reaxios/components/ListItems/AssignmentListItem.dart';
import 'package:reaxios/components/ListItems/GradeListItem.dart';
import 'package:reaxios/components/LowLevel/GradientAppBar.dart';
import 'package:reaxios/components/LowLevel/GradientCircleAvatar.dart';
import 'package:reaxios/components/LowLevel/ReloadableState.dart';
import 'package:reaxios/components/Utilities/BigCard.dart';
import 'package:reaxios/components/Charts/GradeAverageChart.dart';
import 'package:reaxios/components/LowLevel/Loading.dart';
import 'package:reaxios/format.dart';
import 'package:reaxios/system/Store.dart';
import 'package:reaxios/utils.dart';
import 'package:styled_widget/styled_widget.dart';

class OverviewPane extends StatefulWidget {
  OverviewPane({
    Key? key,
    required this.session,
    required this.login,
    required this.student,
    required this.store,
    required this.openMainDrawer,
  }) : super(key: key);

  final Axios session;
  final Login login;
  final Student student;
  final RegistroStore store;
  final Function() openMainDrawer;

  @override
  _OverviewPaneState createState() => _OverviewPaneState();
}

class _OverviewPaneState extends ReloadableState<OverviewPane> {
  // List<Assignment> assignments = [];
  // List<Grade> grades = [];
  // List<Topic> topics = [];
  bool loading = true;
  late String lastUUID;
  Period? period;

  ScrollController controller = ScrollController();
  ScrollController horizontalController = ScrollController();

  @override
  void initState() {
    super.initState();
    lastUUID = widget.student.studentUUID;
    initREData();
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
    horizontalController.dispose();
  }

  setState(VoidCallback cb) {
    if (mounted) super.setState(cb);
  }

  initREData() async {
    Future.wait([
      widget.session.getCurrentPeriod().then((p) => setState(() => period = p)),
    ]).then((_) => setState(() => loading = false));
  }

  @override
  Widget build(BuildContext context) {
    // final tmrAssignments = assignments.where(filterTmr).toList();
    // // final todaysGrades = grades.where(filterToday).toList();
    final initialData = [
      <Assignment>[],
      <Topic>[],
      <Grade>[],
    ];

    return Scaffold(
      appBar: loading
          ? GradientAppBar(
              title: Text(
                context.locale.drawer.overview,
              ),
            )
          : null,
      body: loading
          ? LoadingUI()
          : FutureBuilder<List<List<dynamic>>>(
              future: Future.wait([
                widget.store.assignments ?? Future.value([]),
                widget.store.topics ?? Future.value([]),
                widget.store.grades ?? Future.value([]),
              ]),
              initialData: initialData,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                List<List> data =
                    snapshot.hasData ? snapshot.data! : initialData;
                return _buildBody(data[0] as List<Assignment>,
                    data[1] as List<Topic>, data[2] as List<Grade>);

                // return Center(child: CircularProgressIndicator());
              },
            ),
    );
  }

  @override
  rebuild() {
    super.rebuild();
    setState(() {});
  }

  Widget _buildBody(
      List<Assignment> assignments, List<Topic> topics, List<Grade> grades) {
    final student = widget.student;
    // final theme = Theme.of(context);

    if (student.studentUUID != lastUUID) {
      setState(() {
        lastUUID = student.studentUUID;
        loading = true;
      });
      initREData();
    }

    final filterTmr = (Assignment a) {
      final now = DateTime.now();
      return a.date.isAfter(now) &&
              a.date.isBefore(now.add(Duration(days: 1))) ||
          a.date.isSameDay(now);
    };

    final List<Assignment> tmrAssignments =
        assignments.where(filterTmr).toList();
    final List<Topic> pastTopics =
        topics.where((t) => t.date.isBefore(DateTime.now())).toList();
    final List<Topic> latestTopics = pastTopics
        .where((t) => t.date.isSameDay(pastTopics.last.date))
        .toList()
      ..sort((a, b) => a.lessonHour.compareTo(b.lessonHour));
    final List<Grade> latestGrades = grades.reversed.take(3).toList();

    final accent = Theme.of(context).accentColor;

    final topicCards = latestTopics
        .map(
          (e) => ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth:
                  (MediaQuery.of(context).size.width * 0.65).clamp(350, 500),
            ),
            child: BigCard(
              color: accent,
              gradient: true,
              // radius: 4,
              // elevation: 2,
              leading: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GradientCircleAvatar(
                    color: accent.contrastText,
                    foregroundColor: accent,
                    child: Icon(Utils.getBestIconForSubject(
                        e.subject, Icons.calendar_today)),
                  ),
                  if (e.lessonHour.isNotEmpty)
                    Chip(
                      label: Text(
                        formatString(context.locale.main.lessonHour,
                            [e.lessonHour.toString()]),
                        style: TextStyle(color: accent.contrastText),
                      ),
                      backgroundColor: accent.lighten(0.1),
                      visualDensity: VisualDensity.compact,
                    ),
                ],
              ),
              body: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    e.subject,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: accent.contrastText,
                    ),
                  ).padding(bottom: 8),
                  SelectableText(
                    e.topic,
                    style: TextStyle(
                      fontSize: 14,
                      color: accent.contrastText.withOpacity(0.75),
                    ),
                    minLines: 1,
                    maxLines: 3,
                    // overflow: TextOverflow.ellipsis,
                    scrollPhysics: NeverScrollableScrollPhysics(),
                  ).padding(bottom: 8),
                  Text(
                    context.dateToString(e.date),
                    style: Theme.of(context).textTheme.caption!.copyWith(
                          color: accent.contrastText.withOpacity(0.75),
                        ),
                  ),
                ],
              ),
            ),
          ).padding(left: 16),
        )
        .toList();

    final gradeCards = latestGrades
        .map(
          (e) => Hero(
            tag: e.toString(),
            child: GradeListItem(
              grade: e,
              rebuild: rebuild,
              session: widget.session,
              onClick: true,
              // radius: 4,
              // elevation: 2,
            ),
          ).padding(horizontal: 16),
        )
        .toList();

    final items = [
      if (gradeCards.isNotEmpty) ...[
        Text(
          context.locale.overview.latestGrades,
          style: Theme.of(context).textTheme.headline6,
        ).padding(horizontal: 16, top: 8),
        ...gradeCards,
      ],

      if (topicCards.isNotEmpty) ...[
        Text(
          context.locale.overview.latestLessons,
          style: Theme.of(context).textTheme.headline6,
        ).padding(horizontal: 16, top: 8),
        Scrollbar(
          controller: horizontalController,
          child: SingleChildScrollView(
            controller: horizontalController,
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: topicCards,
            ).padding(right: 16),
          ),
        ),
      ],

      if (tmrAssignments.isNotEmpty) ...[
        Text(
          context.locale.overview.homeworkForTomorrow,
          style: Theme.of(context).textTheme.headline6,
        ).padding(horizontal: 16, top: 8),
        _getAssignmentTimeline(tmrAssignments),
      ],

      // Man, this chart lags
      GradeAverageChart(
              store: widget.store, session: widget.session, period: period)
          .padding(all: 16),
    ];

    final toolbarHeight = AppBar().toolbarHeight ?? kToolbarHeight;

    return CustomScrollView(slivers: [
      SliverPersistentHeader(
        pinned: true,
        floating: false,
        delegate: CustomSliverDelegate(
          hideTitleWhenExpanded: false,
          openMenu: widget.openMainDrawer,
          expandedHeight: 185,
          collapsedHeight: MediaQuery.of(context).padding.top + toolbarHeight,
          period: period,
          student: student,
        ),
      ),
      SliverList(
        delegate: SliverChildListDelegate(items),
      ),
    ]);
  }

  Widget _getAssignmentTimeline(List<Assignment> assignments) {
    final now = DateTime.now();
    final List<Assignment> tmrAssignments = assignments
        .where((a) =>
            a.date.isAfter(now) && a.date.isBefore(now.add(Duration(days: 1))))
        .toList();

    return Column(
      children: [
        for (final assignment in tmrAssignments)
          AssignmentListItem(assignment: assignment)
      ],
    );
  }
}

class CustomSliverDelegate extends SliverPersistentHeaderDelegate {
  final double collapsedHeight;
  final double expandedHeight;
  final bool hideTitleWhenExpanded;
  final void Function() openMenu;
  final Student student;
  final Period? period;

  CustomSliverDelegate({
    required this.collapsedHeight,
    required this.expandedHeight,
    required this.openMenu,
    required this.student,
    required this.period,
    this.hideTitleWhenExpanded = true,
  });

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final RegistroStore store = context.watch<RegistroStore>();

    final appBarSize = expandedHeight - shrinkOffset;
    final cardTopPosition = (expandedHeight / 2 - shrinkOffset) / 2; // / 10;
    final proportion = 2 - (expandedHeight / appBarSize);
    final percent = proportion < 0 || proportion > 1 ? 0.0 : proportion;
    return SizedBox(
      height: expandedHeight + expandedHeight / 2,
      child: Stack(
        children: [
          SizedBox(
            height: appBarSize < collapsedHeight ? collapsedHeight : appBarSize,
            child: GradientAppBar(
              leading: IconButton(
                icon: Icon(Icons.menu),
                onPressed: openMenu,
                tooltip: context.materialLocale.openAppDrawerTooltip,
              ),
              elevation: map(percent, 0, 1, 4, 0).toDouble(),
              title: Opacity(
                opacity: hideTitleWhenExpanded ? 1.0 - percent : 1.0,
                child: Text(context.locale.drawer.overview),
              ),
            ),
          ),
          if (percent > 0)
            Positioned(
              left: 0.0,
              right: 0.0,
              top: max(cardTopPosition, 0),
              bottom: 0.0,
              child: Opacity(
                opacity: percent,
                child: Transform.scale(
                  scale: map(percent, 0, 1, 1.12, 1).toDouble(),
                  child: UserCard(
                    student: student,
                    period: period,
                    store: store,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  double get maxExtent => expandedHeight + expandedHeight / 2;

  @override
  double get minExtent => collapsedHeight;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}

class UserCard extends StatelessWidget {
  UserCard({
    required this.student,
    this.period,
    required this.store,
  });

  final Student student;
  final Period? period;
  final RegistroStore store;

  bg(BuildContext context) => Theme.of(context).accentColor;
  get smallTextOpacity => 0.76;

  Widget _buildUserRow(BuildContext context) {
    final fg = getContrastText(bg(context));
    return <Widget>[
      Icon(Icons.account_circle)
          .iconSize(50)
          .iconColor(fg)
          // .decorated(
          //   color: bg(context),
          //   borderRadius: BorderRadius.circular(30),
          // )
          .constrained(height: 50, width: 50)
          .padding(right: 10),
      <Widget>[
        Text(
          student.fullName,
          style: TextStyle(
            color: fg,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
          overflow: TextOverflow.fade,
        ).padding(bottom: 5),
        Text(
          "${context.dateToString(student.birthday)} - ${context.locale.main.getByKey("gender${describeEnum(student.gender)[0]}")}",
          style: TextStyle(
            color: fg.withOpacity(smallTextOpacity),
            fontSize: 12,
          ),
          maxLines: 1,
          overflow: TextOverflow.fade,
        ),
      ].toColumn(crossAxisAlignment: CrossAxisAlignment.start),
    ].toRow();
  }

  Widget _buildUserStats(BuildContext context) {
    return <Widget>[
      FutureBuilder<List<Grade>>(
        builder: (_, snapshot) {
          if (snapshot.hasError || !snapshot.hasData) {
            return _buildUserStatsItem(
                context, "...", context.locale.overview.average);
          }
          final relevantGrades = period == null
              ? snapshot.data!
              : snapshot.data!.where((g) => g.period == period!.desc).toList();
          return _buildUserStatsItem(
              context,
              gradeAverage(relevantGrades).toString(),
              context.locale.overview.average);
        },
        future: store.grades,
      ),
      FutureBuilder<List<Grade>>(
        builder: (_, snapshot) {
          if (snapshot.hasError || !snapshot.hasData) {
            return _buildUserStatsItem(
                context, "...", context.locale.overview.grades);
          }
          return _buildUserStatsItem(context, snapshot.data!.length.toString(),
              context.locale.overview.grades);
        },
        future: store.grades,
      ),
      FutureBuilder<List<Assignment>>(
        builder: (_, snapshot) {
          if (snapshot.hasError || !snapshot.hasData) {
            return _buildUserStatsItem(
                context, "...", context.locale.overview.assignments);
          }
          return _buildUserStatsItem(context, snapshot.data!.length.toString(),
              context.locale.overview.assignments);
        },
        future: store.assignments,
      ),
      FutureBuilder<List<Topic>>(
        builder: (_, snapshot) {
          if (snapshot.hasError || !snapshot.hasData) {
            return _buildUserStatsItem(
                context, "...", context.locale.overview.topics);
          }
          return _buildUserStatsItem(context, snapshot.data!.length.toString(),
              context.locale.overview.topics);
        },
        future: store.topics,
      ),
    ]
        .toRow(mainAxisAlignment: MainAxisAlignment.spaceAround)
        .padding(vertical: 10);
  }

  Widget _buildUserStatsItem(BuildContext context, String value, String text) {
    final fg = getContrastText(bg(context));
    return <Widget>[
      Text(value).fontSize(20).textColor(fg).padding(bottom: 5),
      Text(text).textColor(fg.withOpacity(smallTextOpacity)).fontSize(12),
    ].toColumn();
  }

  @override
  Widget build(BuildContext context) {
    final bg = this.bg(context);
    return <Widget>[_buildUserRow(context), _buildUserStats(context)]
        .toColumn(mainAxisAlignment: MainAxisAlignment.spaceAround)
        .padding(horizontal: 20, vertical: 10)
        .decorated(
          gradient: LinearGradient(
            colors: getGradient(bg),
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
          borderRadius: BorderRadius.circular(20),
        )
        .elevation(
          5,
          shadowColor: bg,
          borderRadius: BorderRadius.circular(20),
        )
        .height(175)
        .alignment(Alignment.center)
        .padding(top: 32, bottom: 16, horizontal: 16);
  }
}
