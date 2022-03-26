// ignore_for_file: unnecessary_cast, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reaxios/api/Axios.dart';
import 'package:reaxios/api/entities/Absence/Absence.dart';
import 'package:reaxios/api/entities/Grade/Grade.dart';
import 'package:reaxios/api/entities/Structural/Structural.dart';
import 'package:reaxios/api/entities/Topic/Topic.dart';
import 'package:reaxios/api/utils/utils.dart' hide gradeAverage;
import 'package:reaxios/components/Charts/GradeTimeAverageChart.dart';
import 'package:reaxios/components/LowLevel/GradientCircleAvatar.dart';
import 'package:reaxios/components/Utilities/BigCard.dart';
import 'package:reaxios/components/Utilities/CardListItem.dart';
import 'package:reaxios/components/Utilities/GradeText.dart';
import 'package:reaxios/components/Utilities/MaxWidthContainer.dart';
import 'package:reaxios/components/Utilities/NiceHeader.dart';
import 'package:reaxios/system/Store.dart';
import 'package:reaxios/timetable/structures/Settings.dart';
import 'package:reaxios/utils.dart';
import 'package:styled_widget/styled_widget.dart';

import '../../cubit/app_cubit.dart';

// lang: it

class _Tuple2<T1, T2> {
  final T1 item1;
  final T2 item2;

  _Tuple2(this.item1, this.item2);

  factory _Tuple2.fromList(List<dynamic> list) {
    return _Tuple2(list[0] as T1, list[1] as T2);
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
    return FutureBuilder<_Tuple2<List<Period>, List<Absence>>>(
      future: Future.wait(<Future<dynamic>>[
        store.periods ?? Future.value(<Period>[]),
        store.absences ?? Future.value(<Absence>[]),
      ]).then((elements) => _Tuple2.fromList(elements)),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return AnimatedBuilder(
            animation: Provider.of<Settings>(context),
            builder: (BuildContext context, Widget? child) {
              return _buildStats(snapshot.requireData);
            },
          );
        } else if (snapshot.hasError) {
          return Text('${snapshot.error}');
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildStats(_Tuple2<List<Period>, List<Absence>> data) {
    final cubit = context.watch<AppCubit>();
    final grades = cubit.grades;
    final settings = Provider.of<Settings>(context);
    final averageMode = settings.getAverageMode();
    final periods = data.item1;

    final currentPeriod = (periods as List<Period?>).firstWhere(
        (element) => element?.isCurrent() ?? false,
        orElse: () => null);
    final currentGrades = grades
        .where((element) =>
            currentPeriod == null ? true : element.period == currentPeriod.desc)
        .toList();
    final gradesByGrade = currentGrades.toSet().toList()
      ..sort((a, b) => a.grade.compareTo(b.grade));
    final best = gradeAverage(
      averageMode,
      currentGrades
          .where((g) => g.subject == gradesByGrade.last.subject)
          .toList(),
    );
    final worst = gradeAverage(
      averageMode,
      currentGrades
          .where((g) => g.subject == gradesByGrade.first.subject)
          .toList(),
    );
    final over6 = currentGrades
        .map((e) => e.subject)
        .where(
          (g) =>
              gradeAverage(
                averageMode,
                currentGrades.where((element) => element.subject == g).toList(),
              ) >=
              6,
        )
        .toSet()
        .toList();
    final under6 = currentGrades
        .map((e) => e.subject)
        .where(
          (g) =>
              gradeAverage(
                averageMode,
                currentGrades.where((element) => element.subject == g).toList(),
              ) <
              6,
        )
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
            text: GradeText(
              context,
              grade: gradeAverage(averageMode, currentGrades),
            ),
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
