import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:reaxios/components/LowLevel/RestartWidget.dart';
import 'package:reaxios/enums/AverageMode.dart';
import 'package:reaxios/enums/GradeDisplay.dart';
import 'package:reaxios/screens/settings/base.dart';
import 'package:reaxios/timetable/structures/Settings.dart';
import 'package:reaxios/utils.dart';

class GeneralSettings extends BaseSettings {
  const GeneralSettings({Key? key}) : super(key: key);

  @override
  List<SettingsTile> getTiles(BuildContext context, Settings settings) {
    return [
      SettingsTileGroup(
        title: SettingsHeaderTile(
          title:
              Text(context.loc.translate("generalSettings.groupsColorsTitle")),
        ),
        children: [
          if (!kIsWeb) ...[
            SwitchSettingsTile(
              title:
                  Text(context.loc.translate("generalSettings.dynamicColor")),
              subtitle: Text(
                  context.loc.translate("generalSettings.dynamicColorExpl")),
              onChange: (value) => settings.setUseDynamicColor(value),
              value: settings.getUseDynamicColor(),
            ),
          ],
          ColorTile(
            title:
                Text(context.loc.translate("generalSettings.colorSecondary")),
            onChange: (color) => settings.setPrimaryColor(color),
            value: settings.getPrimaryColor(),
          ),
          ColorTile(
            title: Text(context.loc.translate("generalSettings.colorPrimary")),
            onChange: (color) => settings.setAccentColor(color),
            value: settings.getAccentColor(),
          ),
          SwitchSettingsTile(
            title:
                Text(context.loc.translate("generalSettings.harmonizeColors")),
            subtitle: Text(
                context.loc.translate("generalSettings.harmonizeColorsExpl")),
            onChange: (harmonizeColors) =>
                settings.setHarmonizeColors(harmonizeColors),
            value: settings.getHarmonizeColors(),
          ),
          SwitchSettingsTile(
            title: Text(context.loc.translate("generalSettings.useGradients")),
            subtitle:
                Text(context.loc.translate("generalSettings.useGradientsExpl")),
            onChange: (useGradients) => settings.setUseGradients(useGradients),
            value: settings.getUseGradients(),
          ),
          RadioModalTile(
            title: Text(context.loc.translate("generalSettings.colorTheme")),
            values: {
              "light": context.loc.translate("generalSettings.colorThemeLight"),
              "dark": context.loc.translate("generalSettings.colorThemeDark"),
              "dynamic":
                  context.loc.translate("generalSettings.colorThemeDynamic"),
            },
            selectedValue: settings.getThemeMode(),
            onChange: (value) {
              if (value is String) {
                settings.setThemeMode(value);
              }
            },
          ),
        ],
      ),
      SettingsTileGroup(
        title: SettingsHeaderTile(
          title: Text(
              context.loc.translate("generalSettings.groupsBehaviorTitle")),
        ),
        children: [
          RadioModalTile(
            title: Text(
                context.loc.translate("generalSettings.gradeDisplayLabel")),
            values: {
              GradeDisplay.decimal.serialized:
                  context.loc.translate("generalSettings.gradeDisplayDecimal"),
              GradeDisplay.letter.serialized:
                  context.loc.translate("generalSettings.gradeDisplayLetter"),
              GradeDisplay.percentage.serialized: context.loc
                  .translate("generalSettings.gradeDisplayPercentage"),
              GradeDisplay.precise.serialized:
                  context.loc.translate("generalSettings.gradeDisplayPrecise"),
            },
            selectedValue: settings.getGradeDisplay().serialized,
            onChange: (dynamic value) {
              print("Value changed: $value");
              settings.setGradeDisplay(deserializeGradeDisplay(value));
            },
          ),
          RadioModalTile(
            title:
                Text(context.loc.translate("generalSettings.averageModeLabel")),
            subtitle: Text(
                context.loc.translate("generalSettings.averageModeSubtitle")),
            values: {
              AverageMode.allGradesAverage.serialized:
                  context.loc.translate("generalSettings.averageModeAllGrades"),
              AverageMode.averageOfAverages.serialized: context.loc
                  .translate("generalSettings.averageModeAverageOfAverages"),
            },
            selectedValue: settings.getAverageMode().serialized,
            onChange: (dynamic value) {
              print("Value changed: $value");
              settings.setAverageMode(deserializeAverageMode(value));
            },
          ),
          TextFormFieldModalTile(
            title: Text(context.loc.translate("generalSettings.ignoredWords")),
            value: settings.getIgnoreList().join(" "),
            onChange: (ignored) => settings.setIgnoreList(ignored),
          ),
        ],
      ),
      SettingsTileGroup(
        title: SettingsHeaderTile(
          title: Text(
              context.loc.translate("generalSettings.groupsAdvancedTitle")),
        ),
        children: [
          SettingsListTile(
            title:
                Text(context.loc.translate("generalSettings.restartAppTitle")),
            subtitle: Text(
                context.loc.translate("generalSettings.restartAppSubtitle")),
            onTap: () async {
              RestartWidget.restartApp(context);
            },
          ),
        ],
      ),
    ];
  }
}
