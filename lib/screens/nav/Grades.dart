import 'dart:math';

import 'package:flutter/material.dart';
import 'package:reaxios/api/Axios.dart';
import 'package:reaxios/api/entities/Grade/Grade.dart';
import 'package:reaxios/api/entities/Structural/Structural.dart';
import 'package:reaxios/api/entities/Student/Student.dart';
import 'package:reaxios/api/utils/utils.dart';
import 'package:reaxios/components/Charts/GradeTimeAverageChart.dart';
import 'package:reaxios/components/LowLevel/Empty.dart';
import 'package:reaxios/components/Utilities/BigCard.dart';
import 'package:reaxios/components/Utilities/CardListItem.dart';
import 'package:reaxios/components/Utilities/GradeAvatar.dart';
import 'package:reaxios/components/Utilities/GradeText.dart';
import 'package:reaxios/components/Utilities/MaxWidthContainer.dart';
import 'package:reaxios/components/LowLevel/Loading.dart';
import 'package:reaxios/components/LowLevel/ReloadableState.dart';
import 'package:reaxios/components/Utilities/NiceHeader.dart';
import 'package:reaxios/components/Views/GradeSubjectView.dart';
import 'package:reaxios/system/Store.dart';
import 'package:reaxios/utils.dart';
import 'package:styled_widget/styled_widget.dart';

class GradesPane extends StatefulWidget {
  GradesPane({
    Key? key,
    required this.session,
    required this.openMainDrawer,
    required this.store,
    this.period,
  }) : super(key: key);

  final Axios session;
  final Function() openMainDrawer;
  final RegistroStore store;
  final Period? period;

  @override
  _GradesPaneState createState() => _GradesPaneState();
}

// TODO: Allow setting a period objective; show its card above the grades
class _GradesPaneState extends ReloadableState<GradesPane> {
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
      return EmptyUI(
        text: "Non hai il permesso di visualizzare i voti. "
            "Contatta la scuola per saperne di più.",
        icon: Icons.lock,
      ).padding(horizontal: 16);
    }

    return KeyedSubtree(
      key: key,
      child: FutureBuilder<List<dynamic>>(
        future: Future.wait([
          widget.store.grades as Future,
          widget.store.subjects as Future,
          widget.store.getCurrentPeriod(widget.session),
        ]),
        initialData: [<Grade>[], <String>[], null],
        builder: (BuildContext context, snapshot) {
          if (snapshot.hasError)
            return Scaffold(
              appBar: AppBar(
                title: Text("Voti"),
              ),
              body: Text(
                "${snapshot.error}\n${snapshot is Error ? snapshot.stackTrace : ""}",
              ),
            );
          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            final grades = snapshot.data![0] as List<Grade>? ?? [];
            final subjects = snapshot.data![1] as List<String>? ?? [];
            final period = snapshot.data![2] as Period?;
            return buildOk(context, grades.reversed.toList(), period, subjects);
          }

          return Scaffold(
            appBar: AppBar(
              title: Text("Voti"),
            ),
            body: LoadingUI(),
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

  Widget buildOk(BuildContext context, List<Grade> grades,
      Period? currentPeriod, List<String> subjects) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Voti"),
        leading: Builder(builder: (context) {
          return IconButton(
            tooltip: "Apri il menu di navigazione",
            onPressed: widget.openMainDrawer,
            icon: Icon(Icons.menu),
          );
        }),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(context, grades, currentPeriod),
            MaxWidthContainer(
              child: _buildSubjects(context, subjects, grades, currentPeriod),
            ).center().padding(bottom: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
      BuildContext context, List<Grade> grades, Period? currentPeriod) {
    final periods = grades.map((g) => g.period).toSet().toList();
    final periodCards = [];
    for (final period in periods) {
      final periodGrades = grades.where((g) => g.period == period).toList();
      periodCards.add(
        ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth:
                min(650, max(350, MediaQuery.of(context).size.width * 0.75)),
          ),
          child: BigCard(
            leading: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                NiceHeader(title: "Media", subtitle: period).padding(bottom: 8),
                GradeAvatar(
                  grade: Grade.fakeFromDouble(gradeAverage(periodGrades)),
                )
              ],
            ),
            body: GradeTimeAverageChart(
              grades: periodGrades.reversed.toList(),
            ),
          ),
        ).paddingDirectional(start: 16),
      );
    }

    return Scrollbar(
      controller: horizontalController,
      child: SingleChildScrollView(
        controller: horizontalController,
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: min(
                    650, max(350, MediaQuery.of(context).size.width * 0.75)),
              ),
              child: BigCard(
                leading: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    NiceHeader(title: "Media", subtitle: "Tutto l'anno")
                        .padding(bottom: 8),
                    GradeAvatar(
                      grade: Grade.fakeFromDouble(gradeAverage(grades)),
                    ),
                  ],
                ),
                body: GradeTimeAverageChart(
                  grades: grades.reversed.toList(),
                ),
              ),
            ).paddingDirectional(start: 16),
            ...periodCards,
          ],
        ).paddingDirectional(end: 16),
      ),
    );
  }

  Widget _buildSubjects(
    BuildContext context,
    List<String> subjects,
    List<Grade> grades,
    Period? currentPeriod,
  ) {
    List<Widget> children = [];
    for (String subject in subjects
      ..sort((sa, sb) {
        final subjectGrades1 = grades
            .where((element) => element.subject == sa)
            .toList()
          ..sort((a, b) => b.date.compareTo(a.date));
        final average1 = gradeAverage(subjectGrades1);
        final subjectGrades2 = grades
            .where((element) => element.subject == sb)
            .toList()
          ..sort((a, b) => b.date.compareTo(a.date));
        final average2 = gradeAverage(subjectGrades2);

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
      final average = gradeAverage(subjectGrades);
      final color = getGradeColor(average);
      children.add(
        CardListItem(
          leading: CircleAvatar(
            child: Icon(Utils.getBestIconForSubject(subject, Icons.grade)),
            backgroundColor: color,
            foregroundColor: color.contrastText,
          ),
          title: subject,
          subtitle: RichText(
            text: TextSpan(
              style: Theme.of(context).textTheme.caption,
              children: [
                if (!isNaN(average)) ...[
                  TextSpan(text: "Media: "),
                  GradeText(grade: average),
                ] else
                  TextSpan(text: "Ancora nessun voto."),
              ],
            ),
          ),
          details: isNaN(average)
              ? null
              : Text("Ultimo voto: ${dateToString(subjectGrades.first.date)}"),
          onClick: isNaN(average)
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
