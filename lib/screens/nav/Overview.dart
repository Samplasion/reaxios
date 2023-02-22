// ignore_for_file: deprecated_member_use

import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
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
import 'package:reaxios/components/LowLevel/GradientCircleAvatar.dart';
import 'package:reaxios/components/LowLevel/ReloadableState.dart';
import 'package:reaxios/components/Utilities/BigCard.dart';
import 'package:reaxios/components/Charts/GradeAverageChart.dart';
import 'package:reaxios/components/LowLevel/Loading.dart';
import 'package:reaxios/components/Utilities/CardListItem.dart';
import 'package:reaxios/components/Utilities/MaxWidthContainer.dart';
import 'package:reaxios/components/Utilities/NiceHeader.dart';
import 'package:reaxios/components/Utilities/updates/upgrade_card.dart';
import 'package:reaxios/utils/consts.dart';
import 'package:reaxios/cubit/app_cubit.dart';
import 'package:reaxios/utils/format.dart';
import 'package:reaxios/timetable/extensions.dart';
import 'package:reaxios/timetable/structures/Settings.dart';
import 'package:reaxios/utils/utils.dart' hide ColorUtils;
import 'package:styled_widget/styled_widget.dart';

import '../../components/LowLevel/MaybeMasterDetail.dart';
import '../../timetable/components/essential/EventView.dart';
import '../../timetable/structures/Event.dart';
import '../../utils/values.dart';

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
    // Avoid the error that sometimes appears
    // "setState called during build"
    try {
      if (mounted) super.setState(cb);
    } catch (e) {
      // noop
    }
  }

  initREData() async {
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
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
    return loading ? LoadingUI() : _buildBody();
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
            grades.take(3).toList()..addAll(grades.where((g) => !g.seen)))
        .toList();
    // ..sort((a, b) => b.date.compareTo(a.date));

    final scheme = Theme.of(context).colorScheme;

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
            color: scheme.secondaryContainer,
            gradient: true,
            leading: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: scheme.onSecondaryContainer,
                  foregroundColor: scheme.secondaryContainer,
                  child: Icon(Utils.getBestIconForSubject(
                      e.subject, Icons.calendar_today)),
                ),
                if (e.lessonHour.isNotEmpty)
                  Chip(
                    label: Text(
                      formatString(context.loc.translate("main.lessonHour"),
                          [e.lessonHour.toString()]),
                      style: TextStyle(color: scheme.onSecondaryContainer),
                    ),
                    side: BorderSide.none,
                    backgroundColor: scheme.secondaryContainer.lighten(0.1),
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
                    color: scheme.onSecondaryContainer,
                  ),
                ).padding(bottom: 8),
                Text(
                  e.topic,
                  style: TextStyle(
                    fontSize: 14,
                    color: scheme.onSecondaryContainer.withOpacity(0.75),
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  // scrollPhysics: NeverScrollableScrollPhysics(),
                ).padding(bottom: 8),
                Text(
                  context.dateToString(e.date),
                  style: Theme.of(context).textTheme.caption!.copyWith(
                        color: scheme.onSecondaryContainer.withOpacity(0.75),
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

    final colorScheme = Theme.of(context).colorScheme;
    final items = [
      Center(
        child: MaxWidthContainer(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              margin: EdgeInsets.zero,
              color: colorScheme.secondary,
              child: InkWell(
                borderRadius: BorderRadius.circular(13),
                splashColor: colorScheme.secondaryContainer.withOpacity(0.2),
                onTap: () {
                  // Curriculum
                  widget.switchToTab(16);
                },
                child: DefaultTextStyle.merge(
                  style: TextStyle(color: colorScheme.onSecondary),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: SizedBox(
                            height: 50,
                            width: 50,
                            child: Icon(
                              Icons.account_circle,
                              size: 50,
                              color: colorScheme.onSecondary,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                student.fullName,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.fade,
                              ).padding(bottom: 5),
                              Text(
                                "${context.dateToString(student.birthday)} [${calculateAge(student.birthday)}] - ${context.loc.translate("main.gender${describeEnum(student.gender)[0]}")}",
                                style: TextStyle(
                                  color:
                                      colorScheme.onSecondary.withOpacity(0.76),
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.fade,
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: colorScheme.onSecondary,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),

      QuickLinkContainer(
        openPane: widget.switchToTab,
        children: [
          QuickLink(
            "drawer.assignments",
            Colors.green,
            index: 2,
          ),
          QuickLink(
            "drawer.topics",
            Colors.teal,
            index: 5,
          ),
          QuickLink(
            "drawer.teachingMaterials",
            Colors.orange,
            index: 13,
          ),
          QuickLink(
            "drawer.secretary",
            Colors.indigo,
            index: 7,
          ),
          QuickLink(
            "drawer.timetable",
            Colors.cyan,
            index: 6,
          ),
        ],
      ),

      // The card hides itself when there's
      // no update to show.
      UpgradeCard(),

      if (gradeCards.isNotEmpty)
        ...[
          Text(
            context.loc.translate("overview.latestGrades"),
            style: Theme.of(context).textTheme.headline6,
          ).padding(horizontal: 16, top: 8),
          ...gradeCards,
        ].map((e) => Center(child: MaxWidthContainer(child: e))),

      TodaysEvents(),

      if (tmrAssignments.isNotEmpty)
        ...[
          Text(
            context.loc.translate("overview.homeworkForTomorrow"),
            style: Theme.of(context).textTheme.headline6,
          ).padding(horizontal: 16, top: 8),
          _getAssignmentTimeline(tmrAssignments),
        ].map((e) => Center(child: MaxWidthContainer(child: e))),

      if (topicCards.isNotEmpty) ...[
        MaxWidthContainer(
          child: Text(
            context.loc.translate("overview.latestLessons"),
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

    return StreamBuilder<bool>(
      stream: MaybeMasterDetail.getShowingStream(context),
      initialData: false,
      builder: (context, isShowingMasterSnapshot) {
        final isShowingMaster = isShowingMasterSnapshot.data ?? false;
        return Scaffold(
          appBar: AppBar(
            title: Text(context.loc.translate("drawer.overview")),
            leading: isShowingMaster
                ? null
                : Builder(builder: (context) {
                    return IconButton(
                      tooltip: MaterialLocalizations.of(context)
                          .openAppDrawerTooltip,
                      onPressed: () {
                        widget.openMainDrawer();
                      },
                      icon: Icon(Icons.menu),
                    );
                  }),
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              final cubit = context.read<AppCubit>();
              print(String data) => Logger.d("[${DateTime.now()}] $data");
              print("Loading structural...");
              return cubit.loadStructural(force: true).then((_) {
                print("Loaded structural.");
                print("Loading assignments...");
                return cubit.loadAssignments(force: true);
              }).then((_) {
                print("Loaded assignments.");
                print("Loading grades...");
                return cubit.loadGrades(force: true);
              }).then((_) {
                print("Loaded grades.");
                print("Loading topics...");
                return cubit.loadTopics(force: true);
              }).then((_) {
                print("Loaded topics.");
              });
            },
            child: CustomScrollView(
              controller: controller,
              slivers: [
                SliverList(
                  delegate: SliverChildListDelegate(items),
                ),
              ],
            ),
          ),
        );
      },
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
                  context.loc.translate("overview.todaysEventsTitle"),
                  context.loc.translate("overview.todaysEventsSubtitle"),
                  Icons.access_time,
                ),
              if (events.getTomorrowEvents().isNotEmpty)
                buildCard(
                  events.getTomorrowEvents(),
                  context.loc.translate("overview.tomorrowsEventsTitle"),
                  context.loc.translate("overview.tomorrowsEventsSubtitle"),
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
        child: Column(
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

class QuickLinkContainer extends StatelessWidget {
  final List<QuickLink> children;
  final Function openPane;

  const QuickLinkContainer(
      {required this.children, required this.openPane, super.key});

  @override
  Widget build(BuildContext context) {
    final last = children.length - 1;
    return Column(
      children: [
        for (int i = 0; i <= last; i++)
          _buildRow(context, children[i], i == 0, i == last),
      ],
    );
  }

  Widget _buildRow(
      BuildContext context, QuickLink link, bool isFirst, bool isLast) {
    final pivot = context.harmonize(color: link.color);
    final background = pivot.toSlightGradient(context);
    final foreground = pivot.contrastText;
    final radius = RegistroValues.getRadius(isFirst, isLast);
    return Center(
      child: MaxWidthContainer(
        child: Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: isFirst ? 8 : RegistroValues.interCardPadding,
            bottom: isLast ? 8 : RegistroValues.interCardPadding,
          ),
          child: Container(
            margin: EdgeInsets.zero,
            decoration: BoxDecoration(
              borderRadius: radius,
              gradient: LinearGradient(colors: background),
            ),
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(
                borderRadius: radius,
                splashColor: foreground.withOpacity(0.07),
                onTap: () {
                  // Curriculum
                  openPane(link.index);
                },
                child: DefaultTextStyle.merge(
                  style: TextStyle(color: foreground),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                context.loc.translate(link.l10nKey),
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.fade,
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: foreground,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class QuickLink {
  final String l10nKey;
  final Color color;
  final int index;

  const QuickLink(
    this.l10nKey,
    this.color, {
    required this.index,
  });
}
