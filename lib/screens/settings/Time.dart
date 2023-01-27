import 'package:flutter/material.dart';
import 'package:reaxios/format.dart';
import 'package:reaxios/screens/settings/base.dart';
import 'package:reaxios/timetable/structures/Settings.dart';
import 'package:reaxios/utils.dart';

class TimeSettings extends BaseSettings {
  const TimeSettings({Key? key}) : super(key: key);

  @override
  List<SettingsTile> getTiles(BuildContext context, Settings settings) => [
        SettingsTileGroup(
          title: SettingsHeader(title: context.loc.translate("settings.time")),
          children: [
            RadioModalTile<int>(
              title: Text(
                  context.loc.translate("timeSettings.defaultLessonDuration")),
              values: {
                60: '1hour',
                50: '50minutes',
                40: '40minutes',
                30: '30minutes',
                20: '20minutes',
                15: '15minutes',
                10: '10minutes',
                5: '5minutes',
                1: '1minute',
              }.map(
                (key, value) => MapEntry(
                  key,
                  context.loc.translate("timeSettings.lessonDurations.$value"),
                ),
              ),
              selectedValue: settings.getLessonDuration().inMinutes,
              onChange: (duration) =>
                  settings.setLessonDuration(Duration(minutes: duration)),
            ),
            CheckboxModalTile<int>(
              title: Text(context.loc.translate("timeSettings.enabledDays")),
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
              title: Text(context.loc.translate("timeSettings.numberOfWeeks")),
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
              title:
                  Text(context.loc.translate("timeSettings.resetCurrentWeek")),
              subtitle: Text(
                context.loc.translate("timeSettings.resetCurrentWeekSubtitle", {
                  "0": settings.weekForDate(DateTime.now()).toString(),
                }),
              ),
              onTap: () {
                settings.setFirstWeekDate(DateTime.now());
              },
            ),
          ],
        ),
      ];
}
