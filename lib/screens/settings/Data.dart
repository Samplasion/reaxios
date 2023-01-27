import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:reaxios/components/Views/SubjectObjectivesManagerView.dart';
import 'package:reaxios/format.dart';
import 'package:reaxios/timetable/structures/Settings.dart';
import 'package:reaxios/utils.dart';
import 'base.dart';

class DataSettings extends BaseSettings {
  const DataSettings({Key? key}) : super(key: key);

  @override
  List<SettingsTile> getTiles(BuildContext context, Settings settings) {
    return [
      SettingsTileGroup(
        title: SettingsHeader(title: context.loc.translate("settings.data")),
        children: [
          SubscreenListTile(
            title: Text(context.loc.translate("dataSettings.objectivesTitle")),
            subtitle: Text(Intl.plural(
              settings.getSubjectObjectives().length,
              zero:
                  context.loc.translate("dataSettings.objectivesSubtitleZero"),
              one: context.loc.translate("dataSettings.objectivesSubtitleOne"),
              two: context.loc.translate("dataSettings.objectivesSubtitleTwo"),
              few: context.loc.translate("dataSettings.objectivesSubtitleFew"),
              many:
                  context.loc.translate("dataSettings.objectivesSubtitleMany"),
              other:
                  context.loc.translate("dataSettings.objectivesSubtitleOther"),
              locale: context.currentLocale.languageCode,
            ).format([settings.getSubjectObjectives().length])),
            shouldShowInDescription: true,
            builder: (context) {
              return SubjectObjectivesManagerView();
            },
          ),
        ],
      ),
    ];
  }
}
