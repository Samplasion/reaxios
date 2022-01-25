import 'package:flutter/material.dart';
import 'package:reaxios/format.dart';
import 'package:reaxios/screens/settings/base.dart';
import 'package:reaxios/timetable/structures/Settings.dart';
import 'package:reaxios/utils.dart';

class TimeSettings extends BaseSettings {
  const TimeSettings({Key? key}) : super(key: key);

  @override
  List<SettingsTile> getTiles(BuildContext context, Settings settings) => [
        RadioModalTile<int>(
          title: Text(context.locale.timeSettings.defaultLessonDuration),
          values: const {
            60: '1 hour',
            50: '50 minutes',
            40: '40 minutes',
            30: '30 minutes',
            20: '20 minutes',
            15: '15 minutes',
            10: '10 minutes',
            5: '5 minutes',
            1: '1 minute',
          },
          selectedValue: settings.getLessonDuration().inMinutes,
          onChange: (duration) =>
              settings.setLessonDuration(Duration(minutes: duration)),
        ),
        CheckboxModalTile<int>(
          title: Text(context.locale.timeSettings.enabledDays),
          values: const {
            1: 'Monday',
            2: 'Tuesday',
            3: 'Wednesday',
            4: 'Thursday',
            5: 'Friday',
            6: 'Saturday',
            7: 'Sunday',
          },
          selectedValues: settings.getEnabledDays(),
          onChange: (values) => settings.setEnabledDays(values),
        ),
        RadioModalTile<int>(
          title: Text(context.locale.timeSettings.numberOfWeeks),
          values: const {
            1: '1 week',
            2: '2 weeks',
            3: '3 weeks',
            4: '4 weeks',
          },
          selectedValue: settings.getWeeks(),
          onChange: (weeks) => settings.setWeeks(weeks),
        ),
        ListSettingsTile(
          title: Text(context.locale.timeSettings.resetCurrentWeek),
          subtitle: Text(
            context.locale.timeSettings.resetCurrentWeekSubtitle.format([
              settings.weekForDate(DateTime.now()),
            ]),
          ),
          onTap: () {
            settings.setFirstWeekDate(DateTime.now());
          },
        )
      ];
}
