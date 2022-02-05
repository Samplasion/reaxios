import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:reaxios/components/Views/SubjectObjectivesManagerView.dart';
import 'package:reaxios/format.dart';
import 'package:reaxios/system/Store.dart';
import 'package:reaxios/timetable/structures/Settings.dart';
import 'package:reaxios/utils.dart';
import 'base.dart';

class DataSettings extends BaseSettings {
  const DataSettings({Key? key}) : super(key: key);

  @override
  List<SettingsTile> getTiles(BuildContext context, Settings settings) {
    final store = Provider.of<RegistroStore>(context);

    return [
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
    ];
  }
}
