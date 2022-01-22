import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reaxios/components/LowLevel/GradientAppBar.dart';
import 'package:reaxios/components/LowLevel/RestartWidget.dart';
import 'package:reaxios/components/Utilities/settings.dart' hide SettingsTile;
import 'package:reaxios/enums/GradeDisplay.dart';
import 'package:reaxios/system/Store.dart';
import 'package:reaxios/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final children = [
      SettingsHeader(
        title: context.locale.settings.groupsColorsTitle,
        subtitle: context.locale.settings.changesRestart,
      ),
      ColorTile(
        prefKey: 'accent-color',
        title: Text(context.locale.settings.colorPrimary),
        defaultValue: Theme.of(context).colorScheme.secondary,
      ),
      ColorTile(
        prefKey: 'primary-color',
        title: Text(context.locale.settings.colorSecondary),
        defaultValue: Theme.of(context).colorScheme.primary,
      ),
      RadioModalTile(
        title: Text(context.locale.settings.colorTheme),
        values: {
          "light": context.locale.settings.colorThemeLight,
          "dark": context.locale.settings.colorThemeDark,
          "dynamic": context.locale.settings.colorThemeDynamic,
        },
        prefKey: 'theme-mode',
        defaultValue: 'dynamic',
      ),
      SettingsHeader(
        title: context.locale.settings.groupsBehaviorTitle,
      ),
      RadioModalTile<String>(
        prefKey: 'grade-display',
        title: Text(context.locale.settings.gradeDisplayLabel),
        defaultValue: GradeDisplay.decimal.serialized,
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
        onChange: (dynamic value) {
          print("Value changed: $value");
          final store = Provider.of<RegistroStore>(context, listen: false);
          store.gradeDisplay = deserializeGradeDisplay(value);
        },
      ),
      SettingsHeader(
        title: context.locale.settings.groupsAdvancedTitle,
      ),
      ListTile(
        title: Text(context.locale.settings.restartAppTitle),
        subtitle: Text(context.locale.settings.restartAppSubtitle),
        onTap: () async {
          RestartWidget.restartApp(context);
        },
      ),
      if (kDebugMode) ...[
        SettingsHeader(
          title: "[DEBUG] Danger zone",
          subtitle: "[DEBUG] Non usare questi tasti a meno che tu "
              "non sappia cosa stai facendo",
        ),
        ListTile(
          title: Text("[DEBUG] Cancella tutte le impostazioni"),
          subtitle: Text("Non potrai più recuperare i dati una volta toccato "
              "questo pulsante."),
          onTap: () async {
            final prefs = await SharedPreferences.getInstance();
            await prefs.clear();
            Navigator.popUntil(context, (route) => route.isFirst);
            Navigator.pushReplacementNamed(context, "loading");
          },
        ),
      ],
      SizedBox(height: 8),
    ];
    return Scaffold(
      appBar: GradientAppBar(
        title: Text(context.locale.settings.title),
      ),
      body: ListView.builder(
        // shrinkWrap: true,
        itemCount: children.length,
        itemBuilder: (BuildContext context, int index) {
          return children[index];
        },
      ),
    );
  }
}
