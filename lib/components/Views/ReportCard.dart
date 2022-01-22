import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:reaxios/api/entities/ReportCard/ReportCard.dart';
import 'package:reaxios/api/utils/utils.dart';
import 'package:reaxios/components/Utilities/Alert.dart';
import 'package:reaxios/components/Utilities/GradeText.dart';
import 'package:reaxios/format.dart';
import 'package:reaxios/utils.dart';
import 'package:styled_widget/styled_widget.dart';

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
            title: context.locale.reportCard.notAvailableTitle,
            text: MarkdownBody(
              data: context.locale.reportCard.notAvailableBody.mapFormat({
                "day": context.dateToString(reportCard.dateRead),
              }),
            ),
          )
        ],
      );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Alert(
          title: context.locale.reportCard.overview,
          text: [
            RichText(
              text: TextSpan(children: [
                TextSpan(text: context.locale.reportCard.average),
                GradeText(
                  context,
                  grade: simpleAverage(reportCard.subjects
                      .map((e) => e.gradeAverage)
                      .where((e) => e > 0)
                      .toList()),
                ),
              ]),
            ),
            MarkdownBody(data: () {
              String res = "";
              res += "${context.locale.reportCard.absences}\n";
              res += "${context.locale.reportCard.failedSubjects}\n";
              if (reportCard.result.trim().isNotEmpty)
                res += "${context.locale.reportCard.outcome}\n";
              return res.mapFormat({
                "absences": reportCard.subjects
                    .fold<int>(
                      0,
                      (previousValue, ReportCardSubject? element) =>
                          previousValue + (element?.absences ?? 0).toInt(),
                    )
                    .toString(),
                "failedSubjects": carenze.toString(),
                "outcome": reportCard.result,
              });
            }()),
          ].toColumn(),
        ),
        Alert(
          title: context.locale.reportCard.judgment,
          text: RichText(
            text: TextSpan(text: reportCard.rating),
          ),
          selectable: true,
        ),
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
                        TextSpan(text: context.locale.reportCard.grade),
                        e.details[0].grade == 0
                            ? TextSpan(text: "-")
                            : GradeText(context,
                                grade: e.details[0].grade.toDouble())
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
                                    context.locale.reportCard.subjAbsences,
                                    e.absences.toInt().toString(),
                                  ),
                                  Divider(),
                                ]
                              : []),
                          if (e.details.length > 0) ...[
                            DataRow(context.locale.reportCard.subjKind,
                                e.details[0].label),
                            if (e.details[0].grade > 0)
                              DataRow(
                                context.locale.reportCard.subjGrade,
                                RichText(
                                  text: GradeText(
                                    context,
                                    grade: e.details[0].grade.toDouble(),
                                    label: e.details[0].textGrade,
                                  ),
                                ),
                              ),
                          ]
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
