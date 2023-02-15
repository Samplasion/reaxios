import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:reaxios/components/LowLevel/RestartWidget.dart';
import 'package:reaxios/enums/AverageMode.dart';
import 'package:reaxios/enums/GradeDisplay.dart';
import 'package:reaxios/screens/settings/base.dart';
import 'package:reaxios/timetable/structures/Settings.dart';
import 'package:reaxios/utils/utils.dart';

import '../panes.dart';

class GeneralSettings extends BaseSettings {
  const GeneralSettings({Key? key}) : super(key: key);

  @override
  List<SettingsTile> getTiles(
    BuildContext context,
    Settings settings,
    Function setState,
  ) {
    return [
      SettingsTileGroup(
        title: SettingsHeaderTile(
          title:
              Text(context.loc.translate("generalSettings.groupsColorsTitle")),
        ),
        children: [
          if (!kIsWeb && context.supportsDynamicColor()) ...[
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
          SwitchSettingsTile(
            key: ValueKey("useCustomSecondary"),
            title: Text(
                context.loc.translate("generalSettings.useCustomSecondary")),
            subtitle: Text(context.loc
                .translate("generalSettings.useCustomSecondaryExpl")),
            value: settings.getUseCustomSecondary(),
            onChange: (useCustomSecondary) {
              settings.setUseCustomSecondary(useCustomSecondary);
            },
          ),
          ConditionalListTile(
            show: settings.getUseCustomSecondary(),
            child: ColorTile(
              title:
                  Text(context.loc.translate("generalSettings.colorPrimary")),
              onChange: (color) => settings.setAccentColor(color),
              value: settings.getAccentColor(),
            ),
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
            title:
                Text(context.loc.translate("generalSettings.openingPageLabel")),
            values: {
              for (final pane in paneList.where((pane) => pane.isShown))
                pane.id: context.loc.translate(pane.titleKey),
            },
            selectedValue: settings.getOpeningPage(),
            onChange: (dynamic value) {
              if (value is! String || !panes.containsKey(value)) return;
              settings.setOpeningPage(value);
            },
          ),
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
          if (kDebugMode)
            SliderListTile(
              title: Text("[DEBUG] Time dilation"),
              min: 1,
              max: 10,
              value: timeDilation,
              divisions: 9,
              onChanged: (value) {
                setState(() {
                  timeDilation = value;
                });
              },
            ),
        ],
      ),
    ];
  }
}
