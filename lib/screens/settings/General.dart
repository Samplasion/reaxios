import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
        title: Text(context.locale.settings.groupsColorsTitle),
        subtitle: context.locale.settings.changesRestart,
      ),
      ColorTile(
        title: Text(context.locale.settings.colorPrimary),
        onChange: (color) => settings.setAccentColor(color),
        value: settings.getAccentColor(),
      ),
      ColorTile(
        title: Text(context.locale.settings.colorSecondary),
        onChange: (color) => settings.setPrimaryColor(color),
        value: settings.getPrimaryColor(),
      ),
      RadioModalTile(
        title: Text(context.locale.settings.colorTheme),
        values: {
          "light": context.locale.settings.colorThemeLight,
          "dark": context.locale.settings.colorThemeDark,
          "dynamic": context.locale.settings.colorThemeDynamic,
        },
        selectedValue: settings.getThemeMode(),
        onChange: (value) {
          if (value is String) {
            settings.setThemeMode(value);
          }
        },
      ),
      SettingsHeaderTile(
        title: Text(context.locale.settings.groupsBehaviorTitle),
      ),
      RadioModalTile(
        title: Text(context.locale.settings.gradeDisplayLabel),
        values: {
          GradeDisplay.decimal.serialized:
              context.locale.settings.gradeDisplayDecimal,
          GradeDisplay.letter.serialized:
              context.locale.settings.gradeDisplayLetter,
          GradeDisplay.percentage.serialized:
              context.locale.settings.gradeDisplayPercentage,
          GradeDisplay.precise.serialized:
              context.locale.settings.gradeDisplayPrecise,
        },
        selectedValue: settings.getGradeDisplay().serialized,
        onChange: (dynamic value) {
          print("Value changed: $value");
          settings.setGradeDisplay(deserializeGradeDisplay(value));
          store.gradeDisplay = deserializeGradeDisplay(value);
        },
      ),
      TextFormFieldModalTile(
        title: Text("context.locale.generalSettings.ignoredWords"),
        value: settings.getIgnoreList().join(" "),
        onChange: (ignored) => settings.setIgnoreList(ignored),
      ),
    ];
  }
}
