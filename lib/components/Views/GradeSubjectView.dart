import 'package:flutter/material.dart';
import 'package:reaxios/api/Axios.dart';
import 'package:reaxios/api/entities/Grade/Grade.dart';
import 'package:reaxios/api/entities/Structural/Structural.dart';
import 'package:reaxios/api/utils/utils.dart';
import 'package:reaxios/average.dart';
import 'package:reaxios/components/Charts/GradeLineChart.dart';
import 'package:reaxios/components/ListItems/GradeListItem.dart';
import 'package:reaxios/components/LowLevel/ReloadableState.dart';
import 'package:reaxios/components/Utilities/Alert.dart';
import 'package:reaxios/components/Utilities/BigCard.dart';
import 'package:reaxios/components/Utilities/CardListItem.dart';
import 'package:reaxios/components/Utilities/GradeAvatar.dart';
import 'package:reaxios/components/Utilities/GradeText.dart';
import 'package:reaxios/components/Utilities/NiceHeader.dart';
import 'package:reaxios/utils.dart';
import 'package:styled_widget/styled_widget.dart';

class GradeSubjectView extends StatefulWidget {
  final String subject;
  final List<Grade> grades;
  final Axios session;
  final Period? period;

  GradeSubjectView({
    Key? key,
    required this.subject,
    required this.grades,
    required this.session,
    this.period,
  }) : super(key: key);

  @override
  _GradeSubjectViewState createState() => _GradeSubjectViewState();
}

class _GradeSubjectViewState extends ReloadableState<GradeSubjectView> {
  List<Grade> get grades => widget.grades;
  String get subject => widget.subject;
  Axios get session => widget.session;
  Period? get period => widget.period;

  @override
  void rebuild() {
    super.rebuild();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(subject),
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    final periodGrades = grades
        .where(
            (element) => period == null ? true : element.period == period!.desc)
        .toList();
    final items = [
      _buildTeacher(context),
      _buildKindCards(context),
      GradeLineChart(periodGrades, period: period),
      if (period != null && periodGrades.isNotEmpty)
        _buildTarget(context, periodGrades),
      ...grades.map((grade) => _buildGrade(context, grade)),
      SizedBox(height: 8)
    ];

    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) => items[index],
    );
  }

  Widget _buildTeacher(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    final title = teachers.length > 1 ? 'Docenti' : "Docente";
    final icon = teachers.length > 1 ? Icons.people : Icons.person;
    return CardListItem(
      leading: CircleAvatar(
        child: Icon(icon),
        backgroundColor: primary,
        foregroundColor: primary.contrastText,
      ),
      title: title,
      subtitle: Text(teachers.join(", ")),
    ).padding(horizontal: 16);
  }

  Widget _buildKindCards(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    return Column(
      children: kinds.entries.map((entry) {
        final gradeNumber = grades
            .where((element) => element.kind == entry.key && element.weight > 0)
            .length;
        return CardListItem(
          leading: CircleAvatar(
            child: GradeAvatar(grade: Grade.fakeFromDouble(entry.value)),
            backgroundColor: primary,
            foregroundColor: primary.contrastText,
          ),
          title: entry.key,
          subtitle: Text("$gradeNumber vot${gradeNumber == 1 ? "o" : "i"}"),
        ).padding(horizontal: 16);
      }).toList(),
    );
  }

  Widget _buildTarget(BuildContext context, List<Grade> grades) {
    final primary = Theme.of(context).primaryColor;

    return BigCard(
      leading: NiceHeader(
        title: "Obiettivo",
        subtitle: period!.desc,
        leading: Icon(Icons.assessment),
      ),
      body: _buildAlert(context, grades),
    ).padding(horizontal: 16);
  }

  Widget _buildAlert(BuildContext context, List<Grade> grades) {
    final periodAvg = gradeAverage(grades);

    final to = (n, [s = 1]) => widget.period == null
        ? 0
        : toReachAverage(grades.map((g) => [g.grade, g.weight]).toList(), n, s)
            .toDouble();
    final shade = Theme.of(context).brightness == Brightness.dark ? 400 : 700;

    if (periodAvg < 5) {
      return Alert(
        title: "Media inferiore a 5",
        color: Colors.red,
        text: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: "Hai una media inferiore a 5. Devi prendere almeno un ",
              ),
              GradeText(
                grade: to(6).toDouble(),
                shade: shade,
              ),
              TextSpan(
                text: " o due ",
              ),
              GradeText(
                grade: to(6, 2).toDouble(),
                shade: shade,
              ),
              TextSpan(
                text: " per ottenere la sufficienza!",
              ),
            ],
          ),
        ),
      );
    } else if (periodAvg < 6) {
      return Alert(
        title: "Media quasi sufficiente",
        color: Colors.orange,
        text: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text:
                    "Hai una media quasi sufficiente. Devi prendere almeno un ",
              ),
              GradeText(
                grade: to(6).toDouble(),
                shade: shade,
              ),
              if (grades.length > 4)
                TextSpan(
                  text: " o due ",
                ),
              if (grades.length > 4)
                GradeText(
                  grade: to(6, 2).toDouble(),
                  shade: shade,
                ),
              TextSpan(
                text: " per ottenere la sufficienza. Tieni duro!",
              ),
            ],
          ),
        ),
      );
    } else if (periodAvg < 7) {
      return Alert(
        title: "Media superiore a ${periodAvg.floor()}",
        color: Colors.green,
        text: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text:
                    "Hai una media superiore a ${periodAvg.floor()}. Prendi un ",
              ),
              GradeText(
                grade: to(7).toDouble(),
                shade: shade,
              ),
              TextSpan(
                text: " per assicurarti il ",
              ),
              GradeText(
                grade: 7,
                shade: shade,
              ),
              TextSpan(
                text: "!",
              ),
            ],
          ),
        ),
      );
    } else if (periodAvg < 8) {
      return Alert(
        title: "Media superiore a ${periodAvg.floor()}",
        color: Colors.green,
        text: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text:
                    "Hai una media superiore a ${periodAvg.floor()}. Prendi un ",
              ),
              GradeText(
                grade: to(8).toDouble(),
                shade: shade,
              ),
              TextSpan(
                text: " per assicurarti l'",
              ),
              GradeText(
                grade: 8,
                shade: shade,
              ),
              TextSpan(
                text: "!",
              ),
            ],
          ),
        ),
      );
    } else {
      return Alert(
        title: "Vai alla grande!",
        color: Colors.green,
        text: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: "Vai alla grande! 🎉",
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildGrade(BuildContext context, Grade grade) {
    return Hero(
            child: GradeListItem(
              grade: grade,
              rebuild: rebuild,
              session: session,
              onClick: true,
            ),
            tag: grade.toString())
        .padding(horizontal: 16);
  }

  List<String> get teachers =>
      grades.map((grade) => grade.teacher).toSet().toList();

  Map<String, double> get kinds {
    Map<String, double> kinds;

    // Get the set of kinds from the grades (each grade has one kind) and add them to the map with their average as the value
    final kindList = grades.map((grade) => grade.kind).toSet();
    kinds = Map.fromIterable(kindList,
        key: (kind) => kind,
        value: (kind) =>
            gradeAverage(grades.where((grade) => grade.kind == kind).toList()));

    return kinds;
  }
}
