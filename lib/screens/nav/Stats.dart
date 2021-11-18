// ignore_for_file: unnecessary_cast, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reaxios/api/Axios.dart';
import 'package:reaxios/api/entities/Absence/Absence.dart';
import 'package:reaxios/api/entities/Grade/Grade.dart';
import 'package:reaxios/api/entities/Structural/Structural.dart';
import 'package:reaxios/api/entities/Topic/Topic.dart';
import 'package:reaxios/api/utils/utils.dart';
import 'package:reaxios/components/Charts/GradeTimeAverageChart.dart';
import 'package:reaxios/components/LowLevel/GradientCircleAvatar.dart';
import 'package:reaxios/components/Utilities/BigCard.dart';
import 'package:reaxios/components/Utilities/CardListItem.dart';
import 'package:reaxios/components/Utilities/GradeText.dart';
import 'package:reaxios/components/Utilities/MaxWidthContainer.dart';
import 'package:reaxios/components/Utilities/NiceHeader.dart';
import 'package:reaxios/system/Store.dart';
import 'package:reaxios/utils.dart';
import 'package:styled_widget/styled_widget.dart';

// lang: it

class _Tuple4<T1, T2, T3, T4> {
  final T1 item1;
  final T2 item2;
  final T3 item3;
  final T4 item4;

  _Tuple4(this.item1, this.item2, this.item3, this.item4);

  factory _Tuple4.fromList(List<dynamic> list) {
    return _Tuple4(list[0] as T1, list[1] as T2, list[2] as T3, list[3] as T4);
  }
}

class StatsPane extends StatefulWidget {
  final Axios session;

  StatsPane({Key? key, required this.session}) : super(key: key);

  @override
  _StatsPaneState createState() => _StatsPaneState();
}

class _StatsPaneState extends State<StatsPane> {
  @override
  Widget build(BuildContext context) {
    return MaxWidthContainer(child: _buildBody()).center();
  }

  Widget _buildBody() {
    final store = Provider.of<RegistroStore>(context);
    return FutureBuilder<
        _Tuple4<List<Grade>, List<Period>, List<Absence>, List<Topic>>>(
      future: Future.wait(<Future<dynamic>>[
        store.grades ?? Future.value(<Grade>[]),
        store.periods ?? Future.value(<Period>[]),
        store.absences ?? Future.value(<Absence>[]),
        store.topics ?? Future.value(<Topic>[]),
      ]).then((elements) => _Tuple4.fromList(elements)),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return _buildStats(snapshot.requireData);
        } else if (snapshot.hasError) {
          return Text('${snapshot.error}');
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildStats(
      _Tuple4<List<Grade>, List<Period>, List<Absence>, List<Topic>> data) {
    final store = Provider.of<RegistroStore>(context);
    final grades = data.item1;
    final periods = data.item2;
    final absences = data.item3;
    final topics = data.item4;

    final currentPeriod = (periods as List<Period?>).firstWhere(
        (element) => element?.isCurrent() ?? false,
        orElse: () => null);
    final currentGrades = grades
        .where((element) =>
            currentPeriod == null ? true : element.period == currentPeriod.desc)
        .toList();
    final gradesByGrade = currentGrades.toSet().toList()
      ..sort((a, b) => a.grade.compareTo(b.grade));
    final best = gradeAverage(currentGrades
        .where((g) => g.subject == gradesByGrade.last.subject)
        .toList());
    final worst = gradeAverage(currentGrades
        .where((g) => g.subject == gradesByGrade.first.subject)
        .toList());
    final over6 = currentGrades
        .map((e) => e.subject)
        .where((g) =>
            gradeAverage(currentGrades
                .where((element) => element.subject == g)
                .toList()) >=
            6)
        .toSet()
        .toList();
    final under6 = currentGrades
        .map((e) => e.subject)
        .where((g) =>
            gradeAverage(currentGrades
                .where((element) => element.subject == g)
                .toList()) <
            6)
        .toSet()
        .toList();

    final primary = Theme.of(context).primaryColor;
    final accent = Theme.of(context).accentColor;

    final items = <Widget>[
      if (currentGrades.isNotEmpty)
        CardListItem(
          leading: GradientCircleAvatar(
            child: Icon(Icons.grade),
            color: primary,
          ),
          title: context.locale.stats.overallAverage,
          subtitle: RichText(
            text: GradeText(context, grade: gradeAverage(currentGrades)),
          ),
        ).padding(horizontal: 16),
      if (currentGrades.length >= 2) ...[
        CardListItem(
          leading: GradientCircleAvatar(
            child: Icon(Utils.getBestIconForSubject(
                gradesByGrade.last.subject, Icons.book)),
            color: primary,
          ),
          title: context.locale.stats.bestSubject,
          subtitle: Text(gradesByGrade.last.subject),
          details: RichText(
            text: TextSpan(
              style: Theme.of(context).textTheme.caption,
              children: [
                TextSpan(text: context.locale.stats.average),
                GradeText(context, grade: best),
              ],
            ),
          ),
        ).padding(horizontal: 16),
        CardListItem(
          leading: GradientCircleAvatar(
            child: Icon(Utils.getBestIconForSubject(
                gradesByGrade.first.subject, Icons.book)),
            color: accent,
          ),
          title: context.locale.stats.worstSubject,
          subtitle: Text(gradesByGrade.first.subject),
          details: RichText(
            text: TextSpan(
              style: Theme.of(context).textTheme.caption,
              children: [
                TextSpan(text: context.locale.stats.average),
                GradeText(context, grade: worst),
              ],
            ),
          ),
        ).padding(horizontal: 16),
      ],
      CardListItem(
        leading: GradientCircleAvatar(
          child: Icon(Icons.star),
          color: getGradeColor(10),
        ),
        title: context.locale.stats.passedSubjects,
        subtitle: Text(
          over6.length.toString(),
        ),
      ).padding(horizontal: 16),
      CardListItem(
        leading: GradientCircleAvatar(
          child: Icon(Icons.star_half),
          color: getGradeColor(5),
        ),
        title: context.locale.stats.failedSubjects,
        subtitle: Text(
          under6.length.toString(),
        ),
      ).padding(horizontal: 16),
      if (currentGrades.isNotEmpty)
        BigCard(
          leading: NiceHeader(
            title: context.locale.stats.trendHistory,
            subtitle: currentPeriod == null
                ? context.locale.charts.scopeAllYear
                : currentPeriod.desc,
            leading: Icon(Icons.auto_graph).iconSize(40).padding(right: 16),
          ),
          body: Column(
            children: <Widget>[
              GradeTimeAverageChart(grades: currentGrades),
            ],
          ),
        ).padding(horizontal: 16),
    ];

    return ListView.builder(
      itemBuilder: (context, index) {
        return items[index];
      },
      itemCount: items.length,
    );
  }
}
