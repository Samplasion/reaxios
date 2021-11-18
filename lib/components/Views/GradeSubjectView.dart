import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:reaxios/api/Axios.dart';
import 'package:reaxios/api/entities/Grade/Grade.dart';
import 'package:reaxios/api/entities/Structural/Structural.dart';
import 'package:reaxios/api/utils/utils.dart';
import 'package:reaxios/average.dart';
import 'package:reaxios/components/Charts/GradeLineChart.dart';
import 'package:reaxios/components/ListItems/GradeListItem.dart';
import 'package:reaxios/components/LowLevel/GradientAppBar.dart';
import 'package:reaxios/components/LowLevel/GradientCircleAvatar.dart';
import 'package:reaxios/components/LowLevel/ReloadableState.dart';
import 'package:reaxios/components/Utilities/Alert.dart';
import 'package:reaxios/components/Utilities/BigCard.dart';
import 'package:reaxios/components/Utilities/CardListItem.dart';
import 'package:reaxios/components/Utilities/GradeAvatar.dart';
import 'package:reaxios/components/Utilities/GradeText.dart';
import 'package:reaxios/components/Utilities/NiceHeader.dart';
import 'package:reaxios/format.dart';
import 'package:reaxios/structs/GradeAlertBoundaries.dart';
import 'package:reaxios/system/Store.dart';
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
      appBar: GradientAppBar(
        title: Text(subject),
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    final periodGrades = grades
        .where((element) => period == null || period!.desc.isEmpty
            ? true
            : element.period == period!.desc)
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
    final title = Intl.plural(
      teachers.length,
      zero: context.locale.plurals.teachersZero,
      one: context.locale.plurals.teachersOne,
      two: context.locale.plurals.teachersTwo,
      few: context.locale.plurals.teachersFew,
      many: context.locale.plurals.teachersMany,
      other: context.locale.plurals.teachersOther,
    );
    final icon = teachers.length != 1 ? Icons.people : Icons.person;
    return CardListItem(
      leading: GradientCircleAvatar(
        child: Icon(icon),
        color: primary,
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
          leading: GradientCircleAvatar(
            child: GradeAvatar(grade: Grade.fakeFromDouble(entry.value)),
            color: primary,
          ),
          title: entry.key,
          subtitle: Text(
            Intl.plural(
              gradeNumber,
              zero: context.locale.plurals.gradesZero,
              one: context.locale.plurals.gradesOne,
              two: context.locale.plurals.gradesTwo,
              few: context.locale.plurals.gradesFew,
              many: context.locale.plurals.gradesMany,
              other: context.locale.plurals.gradesOther,
            ).format([gradeNumber]),
          ),
        ).padding(horizontal: 16);
      }).toList(),
    );
  }

  Widget _buildTarget(BuildContext context, List<Grade> grades) {
    final primary = Theme.of(context).primaryColor;

    return BigCard(
      leading: NiceHeader(
        title: context.locale.grades.objective,
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

    final store = Provider.of<RegistroStore>(context, listen: false);
    final GradeAlertBoundaries bounds =
        GradeAlertBoundaries.get(store.gradeDisplay);

    if (periodAvg < bounds.underFailure) {
      return Alert(
        title: context.locale.objectives.lt5Title.format([
          context.gradeToString(periodAvg.floor(), round: false),
        ]),
        color: Colors.red,
        text: MarkdownBody(
          data: context.locale.objectives.lt5Text.format([
            context.gradeToString(periodAvg.floor(), round: false),
            context.gradeToString(to(bounds.borderline).toDouble(),
                round: false),
            context.gradeToString(to(bounds.borderline, 2).toDouble(),
                round: false),
          ]),
        ),
      );
    } else if (periodAvg < bounds.borderline) {
      return Alert(
        title: context.locale.objectives.lt6Title.format([
          context.gradeToString(periodAvg.floor(), round: false),
        ]),
        color: Colors.orange,
        text: MarkdownBody(
          data: context.locale.objectives.lt6Text.format([
            context.gradeToString(to(bounds.borderline).toDouble(),
                round: false),
            context.gradeToString(to(bounds.borderline, 2).toDouble(),
                round: false),
          ]),
        ),
      );
    } else if (periodAvg < bounds.successBoundary) {
      return Alert(
        title: context.locale.objectives.lt7Title.format([
          context.gradeToString(bounds.borderline, round: false),
        ]),
        color: Colors.green,
        text: MarkdownBody(
          data: context.locale.objectives.lt7Text.format([
            context.gradeToString(to(bounds.successBoundary).toDouble(),
                round: false),
            context.gradeToString(bounds.successBoundary, round: false),
          ]),
        ),
      );
    } else if (periodAvg < bounds.overSuccess) {
      return Alert(
        title: context.locale.objectives.lt8Title.format([
          context.gradeToString(bounds.successBoundary, round: false),
        ]),
        color: Colors.green,
        text: MarkdownBody(
          data: context.locale.objectives.lt8Text.format([
            context.gradeToString(to(bounds.overSuccess).toDouble(),
                round: false),
            context.gradeToString(bounds.overSuccess, round: false),
          ]),
        ),
      );
    } else {
      return Alert(
        title: context.locale.objectives.otherTitle.format([
          context.gradeToString(periodAvg.floor(), round: false),
        ]),
        color: Colors.green,
        text: MarkdownBody(data: context.locale.objectives.otherText),
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
