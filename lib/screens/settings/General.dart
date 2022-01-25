import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reaxios/components/LowLevel/RestartWidget.dart';
import 'package:reaxios/enums/GradeDisplay.dart';
import 'package:reaxios/screens/settings/base.dart';
import 'package:reaxios/system/Store.dart';
import 'package:reaxios/timetable/structures/Settings.dart';
import 'package:reaxios/utils.dart';

class GeneralSettings extends BaseSettings {
  const GeneralSettings({Key? key}) : super(key: key);

  @override
  List<SettingsTile> getTiles(BuildContext context, Settings settings) {
    final store = Provider.of<RegistroStore>(context);
    return [
      SettingsHeaderTile(
        title: Text(context.locale.generalSettings.groupsColorsTitle),
        subtitle: context.locale.generalSettings.changesRestart,
      ),
      ColorTile(
        title: Text(context.locale.generalSettings.colorPrimary),
        onChange: (color) => settings.setAccentColor(color),
        value: settings.getAccentColor(),
      ),
      ColorTile(
        title: Text(context.locale.generalSettings.colorSecondary),
        onChange: (color) => settings.setPrimaryColor(color),
        value: settings.getPrimaryColor(),
      ),
      RadioModalTile(
        title: Text(context.locale.generalSettings.colorTheme),
        values: {
          "light": context.locale.generalSettings.colorThemeLight,
          "dark": context.locale.generalSettings.colorThemeDark,
          "dynamic": context.locale.generalSettings.colorThemeDynamic,
        },
        selectedValue: settings.getThemeMode(),
        onChange: (value) {
          if (value is String) {
            settings.setThemeMode(value);
          }
        },
      ),
      SettingsHeaderTile(
        title: Text(context.locale.generalSettings.groupsBehaviorTitle),
      ),
      RadioModalTile(
        title: Text(context.locale.generalSettings.gradeDisplayLabel),
        values: {
          GradeDisplay.decimal.serialized:
              context.locale.generalSettings.gradeDisplayDecimal,
          GradeDisplay.letter.serialized:
              context.locale.generalSettings.gradeDisplayLetter,
          GradeDisplay.percentage.serialized:
              context.locale.generalSettings.gradeDisplayPercentage,
          GradeDisplay.precise.serialized:
              context.locale.generalSettings.gradeDisplayPrecise,
        },
        selectedValue: settings.getGradeDisplay().serialized,
        onChange: (dynamic value) {
          print("Value changed: $value");
          settings.setGradeDisplay(deserializeGradeDisplay(value));
          store.gradeDisplay = deserializeGradeDisplay(value);
        },
      ),
      TextFormFieldModalTile(
        title: Text(context.locale.generalSettings.ignoredWords),
        value: settings.getIgnoreList().join(" "),
        onChange: (ignored) => settings.setIgnoreList(ignored),
      ),
      SettingsHeaderTile(
        title: Text(context.locale.generalSettings.groupsAdvancedTitle),
      ),
      SettingsListTile(
        title: Text(context.locale.generalSettings.restartAppTitle),
        subtitle: Text(context.locale.generalSettings.restartAppSubtitle),
        onTap: () async {
          RestartWidget.restartApp(context);
        },
      ),
    ];
  }
}
