// ignore_for_file: deprecated_member_use

import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:reaxios/api/Axios.dart';
import 'package:reaxios/api/entities/Assignment/Assignment.dart';
import 'package:reaxios/api/entities/Grade/Grade.dart';
import 'package:reaxios/api/entities/Login/Login.dart';
import 'package:reaxios/api/entities/Structural/Structural.dart';
import 'package:reaxios/api/entities/Student/Student.dart';
import 'package:reaxios/api/entities/Topic/Topic.dart';
import 'package:reaxios/api/utils/utils.dart' hide gradeAverage;
import 'package:reaxios/components/ListItems/AssignmentListItem.dart';
import 'package:reaxios/components/ListItems/GradeListItem.dart';
import 'package:reaxios/components/LowLevel/GradientAppBar.dart';
import 'package:reaxios/components/LowLevel/GradientCircleAvatar.dart';
import 'package:reaxios/components/LowLevel/ReloadableState.dart';
import 'package:reaxios/components/Utilities/BigCard.dart';
import 'package:reaxios/components/Charts/GradeAverageChart.dart';
import 'package:reaxios/components/LowLevel/Loading.dart';
import 'package:reaxios/components/Utilities/CardListItem.dart';
import 'package:reaxios/components/Utilities/MaxWidthContainer.dart';
import 'package:reaxios/components/Utilities/NiceHeader.dart';
import 'package:reaxios/components/Utilities/updates/upgrade_card.dart';
import 'package:reaxios/consts.dart';
import 'package:reaxios/cubit/app_cubit.dart';
import 'package:reaxios/format.dart';
import 'package:reaxios/timetable/extensions.dart' hide ColorExtension;
import 'package:reaxios/timetable/structures/Settings.dart';
import 'package:reaxios/utils.dart';
import 'package:styled_widget/styled_widget.dart';

import '../../components/LowLevel/MaybeMasterDetail.dart';
import '../../timetable/components/essential/EventView.dart';
import '../../timetable/structures/Event.dart';

class OverviewPane extends StatefulWidget {
  OverviewPane({
    Key? key,
    required this.session,
    required this.login,
    required this.student,
    required this.openMainDrawer,
    required this.switchToTab,
  }) : super(key: key);

  final Axios session;
  final Login login;
  final Student student;
  final Function() openMainDrawer;
  final void Function(int index) switchToTab;

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
    SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {
      final cubit = context.read<AppCubit>();
      if (cubit.structural != null) {
        setState(() {
          period = cubit.currentPeriod;
          loading = false;
        });
      } else {
        cubit.loadStructural().then((p) => setState(() {
              period = cubit.currentPeriod;
              loading = false;
            }));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      return Scaffold(
        appBar: loading
            ? GradientAppBar(
                title: Text(
                  context.locale.drawer.overview,
                ),
              )
            : null,
        body: loading ? LoadingUI() : _buildBody(),
      );
    });
  }

  @override
  rebuild() {
    super.rebuild();
    setState(() {});
  }

  Widget _buildBody() {
    final cubit = context.watch<AppCubit>();
    final assignments = cubit.assignments;
    final grades = cubit.grades;
    final topics = cubit.topics;
    final student = widget.student;

    final screenWidth = MaybeMasterDetail.of(context)?.detailWidth ??
        MediaQuery.of(context).size.width;
    final screenBorders = (screenWidth - kTabBreakpoint) / 2;

    if (student.studentUUID != lastUUID) {
      setState(() {
        lastUUID = student.studentUUID;
        loading = true;
      });
      initREData();
    }

    final now = DateTime.now();
    final List<Assignment> tmrAssignments = assignments
        .where((a) =>
            a.date.isAfter(now) && a.date.isBefore(now.add(Duration(days: 1))))
        .toList();
    final List<Topic> pastTopics =
        topics.where((t) => t.date.isBefore(DateTime.now())).toList();
    final List<Topic> latestTopics = pastTopics
        .where((t) => t.date.isSameDay(pastTopics.last.date))
        .toList()
      ..sort((a, b) => a.lessonHour.compareTo(b.lessonHour));
    final List<Grade> latestGrades = Set<Grade>.from(
            grades.reversed.take(3).toList()
              ..addAll(grades.where((g) => !g.seen)))
        .toList();

    final accent = Theme.of(context).accentColor;

    final topicCards = [
      if (screenBorders > 0)
        SizedBox(
          width: screenBorders,
        ),
      for (Topic e in latestTopics) ...[
        ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: (MaybeMasterDetail.of(context)!.detailWidth * 0.65)
                .clamp(350, 500),
          ),
          child: BigCard(
            color: accent,
            gradient: true,
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
      ],
      if (screenBorders > 0)
        SizedBox(
          width: screenBorders,
        ),
    ];

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
      // The card hides itself when there's
      // no update to show.
      UpgradeCard(),

      if (gradeCards.isNotEmpty)
        ...[
          Text(
            context.locale.overview.latestGrades,
            style: Theme.of(context).textTheme.headline6,
          ).padding(horizontal: 16, top: 8),
          ...gradeCards,
        ].map((e) => MaxWidthContainer(child: e).center()),

      TodaysEvents(),

      if (tmrAssignments.isNotEmpty)
        ...[
          Text(
            context.locale.overview.homeworkForTomorrow,
            style: Theme.of(context).textTheme.headline6,
          ).padding(horizontal: 16, top: 8),
          _getAssignmentTimeline(tmrAssignments),
        ].map((e) => MaxWidthContainer(child: e).center()),

      if (topicCards.isNotEmpty) ...[
        MaxWidthContainer(
          child: Text(
            context.locale.overview.latestLessons,
            style: Theme.of(context).textTheme.headline6,
          ).padding(horizontal: 16, top: 8),
        ).center(),
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

      MaxWidthContainer(
        child: GradeAverageChart(period: period).padding(all: 16),
      ).center(),
    ];

    final toolbarHeight = AppBar().toolbarHeight ?? kToolbarHeight;

    return RefreshIndicator(
      onRefresh: () async {
        final cubit = context.read<AppCubit>();
        // Only await the futures that are most likely to freeze the UI
        cubit.loadStructural(force: true);
        cubit.loadAssignments(force: true);
        await cubit.loadGrades(force: true);
        await cubit.loadTopics(force: true);
      },
      child: CustomScrollView(
        controller: controller,
        slivers: [
          BlocBuilder<AppCubit, AppState>(
            bloc: cubit,
            builder: (context, _) {
              return SliverPersistentHeader(
                pinned: true,
                floating: false,
                delegate: CustomSliverDelegate(
                  hideTitleWhenExpanded: false,
                  openMenu: widget.openMainDrawer,
                  expandedHeight: MediaQuery.of(context).padding.top + 185,
                  collapsedHeight:
                      MediaQuery.of(context).padding.top + toolbarHeight,
                  period: cubit.currentPeriod,
                  student: student,
                  switchToTab: widget.switchToTab,
                ),
              );
            },
          ),
          SliverList(
            delegate: SliverChildListDelegate(items),
          ),
        ],
      ),
    );
  }

  Widget _getAssignmentTimeline(List<Assignment> tmrAssignments) {
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
  final void Function(int index) switchToTab;

  CustomSliverDelegate({
    required this.collapsedHeight,
    required this.expandedHeight,
    required this.openMenu,
    required this.student,
    required this.period,
    required this.switchToTab,
    this.hideTitleWhenExpanded = true,
  });

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    // final RegistroStore store = context.watch<RegistroStore>();
    final appBarSize = (expandedHeight - shrinkOffset);
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
              leading: MaybeMasterDetail.of(context)!.isShowingMaster
                  ? null
                  : IconButton(
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
                child: Transform.rotate(
                  angle: (1 - percent) * 0.07,
                  child: Transform.scale(
                    scale: map(percent, 0, 1, 0.88, 1).toDouble(),
                    child: MaxWidthContainer(
                      child: UserCard(
                        student: student,
                        period: period,
                        // store: store,
                        switchToTab: switchToTab,
                      ),
                    ).center(),
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
  const UserCard({
    required this.student,
    this.period,
    // required this.store,
    required this.switchToTab,
  });

  final Student student;
  final Period? period;
  // final RegistroStore store;
  final void Function(int index) switchToTab;

  bg(BuildContext context) => Theme.of(context).accentColor;
  get smallTextOpacity => 0.76;

  Widget _buildUserRow(BuildContext context) {
    final fg = getContrastText(bg(context));
    return <Widget>[
      Icon(Icons.account_circle)
          .iconSize(50)
          .iconColor(fg)
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
          "${context.dateToString(student.birthday)} [${calculateAge(student.birthday)}] - ${context.locale.main.getByKey("gender${describeEnum(student.gender)[0]}")}",
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
    final cubit = context.watch<AppCubit>();
    return <Widget>[
      AnimatedBuilder(
        animation: Provider.of<Settings>(context),
        builder: (BuildContext context, Widget? child) {
          final averageMode = Provider.of<Settings>(context).getAverageMode();
          final relevantGrades = period == null
              ? cubit.grades
              : cubit.grades.where((g) => g.period == period!.desc).toList();
          return _buildUserStatsItem(
            context,
            gradeAverage(averageMode, relevantGrades).toString(),
            context.locale.overview.average,
            3,
          );
        },
      ),
      _buildUserStatsItem(context, cubit.grades.length.toString(),
          context.locale.overview.grades, 3),
      _buildUserStatsItem(context, cubit.assignments.length.toString(),
          context.locale.overview.assignments, 2),
      _buildUserStatsItem(context, cubit.topics.length.toString(),
          context.locale.overview.topics, 5),
    ]
        .toRow(mainAxisAlignment: MainAxisAlignment.spaceAround)
        .padding(vertical: 10);
  }

  Widget _buildUserStatsItem(BuildContext context, String value, String text,
      [int? index]) {
    final fg = getContrastText(bg(context));
    return <Widget>[
      Text(value).fontSize(20).textColor(fg).padding(bottom: 5),
      Text(text).textColor(fg.withOpacity(smallTextOpacity)).fontSize(12),
    ]
        .toColumn()
        .gestures(onTap: index == null ? null : () => switchToTab(index));
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

class TodaysEvents extends StatelessWidget {
  const TodaysEvents({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<Settings>(context);
    final events = settings.getEvents();
    return Center(
      child: MaxWidthContainer(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (events.getTodayEvents().isNotEmpty)
                buildCard(
                  events.getTodayEvents(),
                  context.locale.overview.todaysEventsTitle,
                  context.locale.overview.todaysEventsSubtitle,
                  Icons.access_time,
                ),
              if (events.getTomorrowEvents().isNotEmpty)
                buildCard(
                  events.getTomorrowEvents(),
                  context.locale.overview.tomorrowsEventsTitle,
                  context.locale.overview.tomorrowsEventsSubtitle,
                  Icons.calendar_today,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildCard(
      List<Event> events, String title, String subtitle, IconData icon) {
    return BigCard(
      leading: NiceHeader(
        title: title,
        subtitle: subtitle,
        leading: Icon(icon),
      ),
      body: Container(
        child: ListView(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          children: events
              .map((event) => EventView(
                    event,
                    expandable: false,
                  ))
              .toList(),
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
        ),
        clipBehavior: Clip.antiAlias,
      ),
    );
  }
}
