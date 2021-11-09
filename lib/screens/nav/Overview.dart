// ignore_for_file: deprecated_member_use

import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
import 'package:reaxios/components/LowLevel/ReloadableState.dart';
import 'package:reaxios/components/Utilities/BigCard.dart';
import 'package:reaxios/components/Charts/GradeAverageChart.dart';
import 'package:reaxios/components/LowLevel/Loading.dart';
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
  }) : super(key: key);

  final Axios session;
  final Login login;
  final Student student;
  final RegistroStore store;

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

    final filterTmr = (a) {
      final now = DateTime.now();
      return a.date.millisecondsSinceEpoch > now.millisecondsSinceEpoch &&
          a.date.millisecondsSinceEpoch < now.millisecondsSinceEpoch + 86400000;
    };

    final List<Assignment> tmrAssignments =
        assignments.where(filterTmr).toList();
    final List<Topic> pastTopics =
        topics.where((t) => t.date.isBefore(DateTime.now())).toList();
    final List<Topic> latestTopics = pastTopics
        .where((t) => t.date.isSameDay(pastTopics.last.date))
        .toList()
      ..sort((a, b) => a.lessonHour.compareTo(b.lessonHour));
    final List<Grade> latestGrades =
        grades.reversed.where((element) => element.weight > 0).take(3).toList();

    final accent = Theme.of(context).accentColor;
    final captionColor = Theme.of(context).textTheme.caption!.color;

    final assmts = tmrAssignments
        .map(
          (e) => ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: max(350, MediaQuery.of(context).size.width * 0.65),
            ),
            child: BigCard(
              leading: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleAvatar(
                    backgroundColor: accent,
                    foregroundColor: accent.contrastText,
                    child: Icon(Icons.book),
                  ),
                  if (e.lessonHour > 0) Chip(label: Text("${e.lessonHour}h")),
                ],
              ),
              body: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    e.subject,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ).padding(bottom: 8),
                  Text(
                    e.assignment,
                    style: TextStyle(
                      fontSize: 14,
                      color: captionColor,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ).padding(left: 16),
        )
        .toList();

    final topicCards = latestTopics
        .map(
          (e) => ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: max(350, MediaQuery.of(context).size.width * 0.65),
            ),
            child: BigCard(
              color: accent,
              // radius: 4,
              // elevation: 2,
              leading: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: accent.contrastText,
                    foregroundColor: accent,
                    child: Icon(Utils.getBestIconForSubject(
                        e.subject, Icons.calendar_today)),
                  ),
                  if (e.lessonHour.isNotEmpty)
                    Chip(
                      label: Text(
                        "${e.lessonHour}\u00aa ora",
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
                    dateToString(e.date),
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
      UserCard(
        student: student,
        period: period,
        store: widget.store,
      ),

      if (gradeCards.isNotEmpty) ...[
        Text(
          "Ultimi voti",
          style: Theme.of(context).textTheme.headline6,
        ).padding(horizontal: 16, top: 8),
        ...gradeCards,
      ],

      if (topicCards.isNotEmpty) ...[
        Text(
          "Ultime lezioni",
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

      if (assmts.isNotEmpty) ...[
        Text(
          "Compiti per domani",
          style: Theme.of(context).textTheme.headline6,
        ).padding(horizontal: 16, top: 8),
        _getAssignmentTimeline(assignments),
      ],

      // Man, this chart lags
      GradeAverageChart(
              store: widget.store, session: widget.session, period: period)
          .padding(all: 16),
    ];

    return ListView.builder(
      itemCount: items.length,
      scrollDirection: Axis.vertical,
      itemBuilder: (context, position) {
        return items[position];
      },
    );
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
          "${dateToString(student.birthday)} - ${describeEnum(student.gender)[0]}",
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
            return _buildUserStatsItem(context, "...", "Media");
          }
          final relevantGrades = period == null
              ? snapshot.data!
              : snapshot.data!.where((g) => g.period == period!.desc).toList();
          return _buildUserStatsItem(
              context, gradeAverage(relevantGrades).toString(), 'Media');
        },
        future: store.grades,
      ),
      FutureBuilder<List<Grade>>(
        builder: (_, snapshot) {
          if (snapshot.hasError || !snapshot.hasData) {
            return _buildUserStatsItem(context, "...", "Voti");
          }
          return _buildUserStatsItem(
              context, snapshot.data!.length.toString(), 'Voti');
        },
        future: store.grades,
      ),
      FutureBuilder<List<Assignment>>(
        builder: (_, snapshot) {
          if (snapshot.hasError || !snapshot.hasData) {
            return _buildUserStatsItem(context, "...", "Compiti");
          }
          return _buildUserStatsItem(
              context, snapshot.data!.length.toString(), 'Compiti');
        },
        future: store.assignments,
      ),
      FutureBuilder<List<Topic>>(
        builder: (_, snapshot) {
          if (snapshot.hasError || !snapshot.hasData) {
            return _buildUserStatsItem(context, "...", "Argomenti");
          }
          return _buildUserStatsItem(
              context, snapshot.data!.length.toString(), 'Argomenti');
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
        .decorated(color: bg, borderRadius: BorderRadius.circular(20))
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
