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
        title: SettingsHeader(title: context.locale.settings.data),
        children: [
          SubscreenListTile(
            title: Text(context.locale.dataSettings.objectivesTitle),
            subtitle: Text(Intl.plural(
              settings.getSubjectObjectives().length,
              zero: context.locale.dataSettings.objectivesSubtitleZero,
              one: context.locale.dataSettings.objectivesSubtitleOne,
              two: context.locale.dataSettings.objectivesSubtitleTwo,
              few: context.locale.dataSettings.objectivesSubtitleFew,
              many: context.locale.dataSettings.objectivesSubtitleMany,
              other: context.locale.dataSettings.objectivesSubtitleOther,
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
