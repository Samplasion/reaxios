import 'package:flutter/material.dart';
import 'package:reaxios/utils/format.dart';
import 'package:reaxios/screens/settings/base.dart';
import 'package:reaxios/structs/SubjectObjective.dart';
import 'package:reaxios/timetable/structures/Settings.dart';
import 'package:reaxios/utils/utils.dart';

class SubjectSettingsView extends StatelessWidget {
  final String subject;
  final String subjectID;
  final int year;
  final Settings settings;

  const SubjectSettingsView({
    required this.subject,
    required this.settings,
    required this.subjectID,
    required this.year,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            context.loc.translate("grades.settingsTitle").format([subject])),
      ),
      body: ListView(
        children: [
          SettingsHeaderTile(
              title: Text(context.loc.translate("grades.objective"))),
          TextFormFieldModalTile(
            title: Text(context.loc.translate("grades.customObjective")),
            subtitle: Text(getSubtitle(context)),
            value: value?.objective.toString() ?? "",
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              errorMaxLines: 10,
              helperText: context.loc.translate("grades.customObjectiveHelper"),
              helperMaxLines: 10,
            ),
            validator: (String? val) {
              if (val != null && val.isNotEmpty) {
                final unlocalized = val.replaceAll(",", ".");
                final doubled = double.tryParse(unlocalized);
                if (doubled == null) {
                  return context.loc.translate("grades.invalidObjective");
                }
                if (doubled <= 0.0 || doubled > 10) {
                  return context.loc.translate("grades.invalidObjective");
                }
              }
            },
            onChange: (String val) {
              if (val.isNotEmpty) {
                final doubled = double.parse(val.replaceAll(",", "."));
                final objective = SubjectObjective(
                  subjectID: subjectID,
                  subjectName: subject,
                  year: year,
                  objective: doubled,
                );
                settings.setSubjectObjectives({
                  ...settings.getSubjectObjectives(),
                  objective.subjectID: objective,
                });
              } else {
                settings.setSubjectObjectives(
                  settings.getSubjectObjectives()..remove(subjectID),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  SubjectObjective? get value {
    return settings.getSubjectObjectives()[subjectID];
  }

  String getSubtitle(BuildContext context) {
    if (value == null) {
      return context.loc.translate("grades.noObjective");
    }
    return context.gradeToString(
      value!.objective,
      round: false,
      showAsNumber: true,
    );
  }
}
