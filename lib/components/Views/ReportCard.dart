import 'package:flutter/material.dart';
import 'package:reaxios/api/entities/ReportCard/ReportCard.dart';
import 'package:reaxios/api/utils/utils.dart';
import 'package:reaxios/components/Utilities/Alert.dart';
import 'package:reaxios/components/Utilities/GradeText.dart';
import '../Utilities/BoldText.dart';

// ignore: must_be_immutable
class ReportCardComponent extends StatefulWidget {
  ReportCardComponent({Key? key, required this.reportCard}) : super(key: key);

  final ReportCard reportCard;

  @override
  _ReportCardComponentState createState() => _ReportCardComponentState();
}

class _ReportCardComponentState extends State<ReportCardComponent> {
  Map<String, bool> openPanels = new Map();
  List<String> subjects = [];

  @override
  Widget build(BuildContext context) {
    final reportCard = widget.reportCard;
    subjects = reportCard.subjects.map((e) => e.name).toList();
    final carenze = reportCard.subjects
        .where((element) =>
            element.details[0].grade > 0 && element.details[0].grade < 6)
        .length;

    subjects.forEach((s) {
      if (!openPanels.containsKey(s)) openPanels[s] = false;
    });

    if (!reportCard.visible)
      return Column(
        children: [
          Alert(
            title: "Pagella non disponibile",
            text: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "La pagella sarà visibile a partire dal: ",
                  ),
                  TextSpan(
                    text: dateToString(reportCard.dateRead),
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          )
        ],
      );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Alert(
          title: "Riepilogo",
          text: RichText(
            text: TextSpan(children: [
              TextSpan(text: "Media: "),
              GradeText(
                grade: simpleAverage(reportCard.subjects
                    .map((e) => e.gradeAverage)
                    .where((e) => e > 0)
                    .toList()),
              ),
              TextSpan(text: "\nAssenze: "),
              BoldText(
                text: reportCard.subjects
                    .fold<int>(
                      0,
                      (previousValue, ReportCardSubject? element) =>
                          previousValue + (element?.absences ?? 0).toInt(),
                    )
                    .toString(),
              ),
              TextSpan(text: "\nCarenze: "),
              BoldText(
                text: carenze.toString(),
                color: getColorIfNonZero(carenze),
              ),
              if (reportCard.result.trim() != "") TextSpan(text: "\nEsito: "),
              if (reportCard.result.trim() != "")
                BoldText(
                  text: reportCard.result,
                ),
            ]),
          ),
        ),
        Alert(
          title: "Giudizio",
          text: RichText(
            text: TextSpan(children: [
              TextSpan(text: reportCard.rating),
            ]),
          ),
          selectable: true,
        ),
        // Card(
        //   child: ExpansionTile(
        //     title: Text("hello"),
        //     subtitle: Text("h,m"),
        //     children: [Text("why hello")],
        //   ),
        // ),
        ExpansionPanelList(
          expansionCallback: (index, open) {
            setState(() {
              openPanels[subjects[index]] = !open;
            });
          },
          children: reportCard.subjects.map((e) {
            return ExpansionPanel(
              isExpanded: openPanels[e.name] ?? true,
              canTapOnHeader: true,
              headerBuilder: (context, isOpen) {
                return ListTile(
                  title: Text(e.name),
                  trailing: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(text: "Voto: "),
                        e.details[0].grade == 0
                            ? TextSpan(text: "-")
                            : GradeText(grade: e.details[0].grade.toDouble())
                      ],
                      style: Theme.of(context).textTheme.caption,
                    ),
                  ),
                  mouseCursor: SystemMouseCursors.click,
                );
              },
              body: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ...(reportCard.canViewAbsences
                              ? [
                                  DataRow(
                                      "Assenze", e.absences.toInt().toString()),
                                  Divider(),
                                ]
                              : []),
                          ...(e.details.length > 0
                              ? [
                                  DataRow("Tipo", e.details[0].label),
                                  if (e.details[0].grade > 0)
                                    DataRow(
                                      "Voto",
                                      RichText(
                                        text: GradeText(
                                          grade: e.details[0].grade.toDouble(),
                                          label: e.details[0].textGrade,
                                        ),
                                      ),
                                    ),
                                ]
                              : [])
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        )
      ],
    );
  }
}

class DataRow extends StatelessWidget {
  const DataRow(this.k, this.v, {Key? key}) : super(key: key);

  final String k;
  final dynamic v;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 35,
          child: Text(
            "$k:",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          flex: 65,
          child: v is String ? Text(v) : v,
        )
      ],
    );
  }
}
