import 'package:flutter/material.dart';
import 'package:reaxios/api/Axios.dart';
import 'package:reaxios/api/entities/Grade/Grade.dart';
import 'package:reaxios/api/entities/Structural/Structural.dart';
import 'package:reaxios/api/entities/Student/Student.dart';
import 'package:reaxios/api/utils/utils.dart';
import 'package:reaxios/average.dart';
import 'package:reaxios/components/Utilities/Alert.dart';
import 'package:reaxios/components/LowLevel/Empty.dart';
import 'package:reaxios/components/Utilities/GradeAvatar.dart';
import 'package:reaxios/components/Charts/GradeLineChart.dart';
import 'package:reaxios/components/ListItems/GradeListItem.dart';
import 'package:reaxios/components/Utilities/GradeText.dart';
import 'package:reaxios/components/Views/GradeView.dart';
import 'package:reaxios/components/LowLevel/Loading.dart';
import 'package:reaxios/components/LowLevel/ReloadableState.dart';
import 'package:reaxios/system/Store.dart';
import 'package:sticky_headers/sticky_headers.dart';
import 'package:styled_widget/styled_widget.dart';

// ignore: import_of_legacy_library_into_null_safe
import '../../main.dart';

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

class _GradesPaneState extends ReloadableState<GradesPane> {
  String selectedSubject = "";

  late ScrollController controller;

  @override
  void initState() {
    super.initState();
    controller = ScrollController();
  }

  @override
  dispose() {
    controller.dispose();
    super.dispose();
  }

  // TODO: Grades più tradizionale

  Map<String, List<Grade>> splitGrades(List<Grade> grades) {
    return grades
        .where((element) =>
            selectedSubject == "" ? true : element.subject == selectedSubject)
        .fold(new Map(), (map, grade) {
      final subj = grade.period;
      if (!map.containsKey(subj))
        map[subj] = [grade];
      else
        map[subj]!.add(grade);

      return map;
    });
  }

  List<String> getSubjects(List<Grade> grades) {
    return (grades).map((e) => e.subject).toSet().toList();
  }

  ListTile formatSubject(List<Grade> grades, String subject) {
    final allGrades =
        grades.where((element) => element.subject == subject).toList();
    Grade _fauxGrade = fauxGrade(allGrades);

    return ListTile(
      title: Text(subject),
      leading: GradeAvatar(
        grade: _fauxGrade,
      ),
      onTap: () {
        setState(() {
          selectedSubject = subject;
          Navigator.pop(context);
        });
      },
    );
  }

  Grade fauxGrade(List<Grade> grades) {
    final allGrades = grades
        .where((element) => widget.period == null
            ? true
            : element.period == widget.period!.desc)
        .toList();
    Grade fauxGrade = Grade.empty();
    fauxGrade.grade = gradeAverage(allGrades);
    fauxGrade.weight =
        allGrades.where((element) => element.weight > 0).length > 0 ? 1 : 0;
    fauxGrade.prettyGrade =
        fauxGrade.weight == 0 ? "" : gradeToString(fauxGrade.grade);
    return fauxGrade;
  }

  Widget buildGradesAlert(BuildContext context, List<Grade> grades) {
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
      ).padding(horizontal: 16);
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
      ).padding(horizontal: 16);
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
      ).padding(horizontal: 16);
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
      ).padding(horizontal: 16);
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
      ).padding(horizontal: 16);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.session.student?.securityBits[SecurityBits.hideGrades] == "1") {
      return EmptyUI(
        text: "Non hai il permesso di visualizzare le autorizzazioni. "
            "Contatta la scuola per saperne di più.",
        icon: Icons.lock,
      ).padding(horizontal: 16);
    }

    return KeyedSubtree(
      key: key,
      child: FutureBuilder<List<dynamic>>(
        future: Future.wait([
          widget.store.grades as Future,
          widget.store.getCurrentPeriod(widget.session),
        ]),
        initialData: [<Grade>[], null],
        builder: (BuildContext context, snapshot) {
          if (snapshot.hasError)
            return Scaffold(
              appBar: AppBar(
                title: Text("Voti"),
              ),
              body: Text("${snapshot.error}"),
            );
          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            final grades = snapshot.data![0] as List<Grade>? ?? [];
            final period = snapshot.data![1] as Period?;
            return buildOk(context, grades.reversed.toList(), period);
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
      [Period? currentPeriod]) {
    print("Build method");
    final width = MediaQuery.of(context).size.width;
    final map = splitGrades(grades);
    final entries = map.entries.toList();

    final subjects = getSubjects(grades);

    return Scaffold(
      endDrawer: Drawer(
        child: ListView(children: [
          Padding(
            padding: EdgeInsets.only(top: 8),
            child: ListTile(
              title: Text("Tutte"),
              leading: GradeAvatar(
                grade: fauxGrade(grades),
              ),
              onTap: () {
                setState(() {
                  selectedSubject = "";
                  Navigator.pop(context);
                });
              },
            ),
          ),
          Divider(),
          ...subjects.map((s) => formatSubject(grades, s)).toList()
            ..sort(
              (a, b) =>
                  (a.title! as Text).data!.compareTo((b.title! as Text).data!),
            ),
        ]),
      ),
      appBar: AppBar(
        title: Text("Voti"),
        leading: Builder(builder: (context) {
          return IconButton(
            tooltip: "Apri il menu di navigazione",
            onPressed: widget.openMainDrawer,
            icon: Icon(Icons.menu),
          );
        }),
        actions: [
          Builder(builder: (context) {
            return IconButton(
              tooltip: "Apri il menu delle materie",
              onPressed: () => Scaffold.of(context).openEndDrawer(),
              icon: Icon(Icons.star),
            );
          }),
        ],
      ),
      body: Container(
        child: ListView(
          controller: controller,
          // crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 16, right: 16, top: 16),
              child: Text(
                selectedSubject == "" ? "Tutti i voti" : selectedSubject,
                style: Theme.of(context).textTheme.headline5,
              ),
            ),
            if (selectedSubject.isEmpty)
              Padding(
                padding: EdgeInsets.only(left: 16, right: 16, top: 16),
                child: Text(
                  "Usa il pulsante con la stella in alto per filtrare i voti per materia.",
                  style: Theme.of(context).textTheme.caption,
                ),
              ),
            if (selectedSubject.isNotEmpty && currentPeriod != null)
              buildGradesAlert(
                context,
                entries
                    .where((element) => element.key == currentPeriod.desc)
                    .map((e) => e.value)
                    .first
                    .toList(),
              ),
            if (selectedSubject.isNotEmpty && currentPeriod != null)
              GradeLineChart(
                entries
                    .where((element) => element.key == currentPeriod.desc)
                    .map((e) => e.value)
                    .first
                    .toList(),
                period: currentPeriod,
              ),
            ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              separatorBuilder: (_a, _b) => Divider(),
              itemBuilder: (context, i) {
                return StickyHeader(
                  header: Container(
                    height: 50.0,
                    color: Theme.of(context).canvasColor,
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    alignment: Alignment.centerLeft,
                    child: entries[i].value.isNotEmpty
                        ? RichText(
                            text: TextSpan(
                              style: Theme.of(context).textTheme.caption,
                              children: [
                                TextSpan(text: "${entries[i].key} ("),
                                GradeText(
                                  grade: gradeAverage(entries[i].value),
                                ),
                                ...(gradeAverage(entries[i].value) % 1 != 0
                                    ? [
                                        TextSpan(text: "/"),
                                        GradeText(
                                          grade: gradeAverage(entries[i].value),
                                          precise: false,
                                        ),
                                      ]
                                    : []),
                                TextSpan(text: ")"),
                              ],
                            ),
                          )
                        : Text(entries[i].key),
                  ),
                  content: Padding(
                    padding: i == entries.length - 1
                        ? EdgeInsets.only(bottom: 16)
                        : EdgeInsets.zero,
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context, i1) {
                        final e = entries[i].value[i1];
                        return Hero(
                          tag: e.toString(),
                          child: GradeListItem(
                            grade: e,
                            onClick: true,
                            session: widget.session,
                            rebuild: rebuild,
                          ),
                        ).padding(horizontal: 16);
                      },
                      itemCount: entries[i].value.length,
                    ),
                  ),
                );
              },
              itemCount: entries.length,
            ),
          ],
        ),
      ),
    );
  }
}
