import 'package:flutter/foundation.dart' as Foundation;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reaxios/components/LowLevel/GradientAppBar.dart';
import 'package:reaxios/components/LowLevel/RestartWidget.dart';
import 'package:reaxios/screens/settings/Time.dart';
import 'package:reaxios/screens/settings/base.dart';
import 'package:reaxios/timetable/structures/Settings.dart';
import 'package:reaxios/utils.dart';

import 'settings/General.dart';

class _Fragment {
  final String title;
  final BaseSettings body;
  final Widget icon;

  _Fragment(this.title, this.body, this.icon);
}

class SettingsScreen extends StatefulWidget {
  SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  List<_Fragment> get _fragments => [
        _Fragment(
          "context.locale.settings.general",
          GeneralSettings(),
          Icon(Icons.settings),
        ),
        _Fragment(
          "context.locale.settings.time",
          TimeSettings(),
          Icon(Icons.access_time),
        ),
      ];

  Settings get settings => Provider.of<Settings>(context, listen: false);

  List<PopupMenuEntry<String>> getPopupItems() {
    return [
      if (!Foundation.kIsWeb) ...[
        PopupMenuItem<String>(
          onTap: () {
            // Navigator.pop(context);
            builder(context) {
              return AlertDialog(
                title: Text("The settings file"),
                content: SingleChildScrollView(
                  child: Text("The settings file is a JSON file that "
                      "contains all your data for this application. "
                      "Store this file in a secure place and don't "
                      "modify it to be able to successfully restore it "
                      "if need be."),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("Close"),
                  ),
                  TextButton(
                    onPressed: () async {
                      await settings.share();
                      Navigator.pop(context);
                    },
                    child: Text("OK"),
                  ),
                ],
              );
            }

            // Required to be able to show the dialog
            // after the pop up menu has been closed
            WidgetsBinding.instance!.addPostFrameCallback((_) {
              showDialog(
                context: context,
                builder: builder,
              );
            });
          },
          child: Text("Export data"),
        ),
        PopupMenuItem<String>(
          onTap: () => settings.load().then((_) {
            RestartWidget.restartApp(context);
          }),
          child: Text("Import data from file"),
        ),
      ]
    ];
  }

  _pushFragment(BuildContext context, _Fragment fragment) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StatefulBuilder(
          builder: (context, setState) => Scaffold(
            appBar: GradientAppBar(
              title: Text(fragment.title),
            ),
            body: fragment.body,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        title: Text(context.locale.drawer.settings),
        actions: [
          if (getPopupItems().isNotEmpty)
            PopupMenuButton<String>(
              onSelected: print,
              itemBuilder: (BuildContext context) {
                return getPopupItems();
              },
            ),
        ],
      ),
      body: ListView.builder(
        itemBuilder: (context, index) {
          final fragment = _fragments[index];
          return ListTile(
            leading: fragment.icon,
            title: Text(fragment.title),
            subtitle: Text(fragment.body.getDescription(context)),
            onTap: () => _pushFragment(context, fragment),
          );
        },
        itemCount: _fragments.length,
      ),
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   final children = [
  //     SettingsHeader(
  //       title: context.locale.settings.groupsColorsTitle,
  //       subtitle: context.locale.settings.changesRestart,
  //     ),
  //     ColorTile(
  //       prefKey: 'accent-color',
  //       title: Text(context.locale.settings.colorPrimary),
  //       defaultValue: Theme.of(context).colorScheme.secondary,
  //     ),
  //     ColorTile(
  //       prefKey: 'primary-color',
  //       title: Text(context.locale.settings.colorSecondary),
  //       defaultValue: Theme.of(context).colorScheme.primary,
  //     ),
  //     RadioModalTile(
  //       title: Text(context.locale.settings.colorTheme),
  //       values: {
  //         "light": context.locale.settings.colorThemeLight,
  //         "dark": context.locale.settings.colorThemeDark,
  //         "dynamic": context.locale.settings.colorThemeDynamic,
  //       },
  //       prefKey: 'theme-mode',
  //       defaultValue: 'dynamic',
  //     ),
  //     SettingsHeader(
  //       title: context.locale.settings.groupsBehaviorTitle,
  //     ),
  //     RadioModalTile<String>(
  //       prefKey: 'grade-display',
  //       title: Text(context.locale.settings.gradeDisplayLabel),
  //       defaultValue: GradeDisplay.decimal.serialized,
  //       values: {
  //         GradeDisplay.decimal.serialized:
  //             context.locale.settings.gradeDisplayDecimal,
  //         GradeDisplay.letter.serialized:
  //             context.locale.settings.gradeDisplayLetter,
  //         GradeDisplay.percentage.serialized:
  //             context.locale.settings.gradeDisplayPercentage,
  //         GradeDisplay.precise.serialized:
  //             context.locale.settings.gradeDisplayPrecise,
  //       },
  //       onChange: (dynamic value) {
  //         print("Value changed: $value");
  //         final store = Provider.of<RegistroStore>(context, listen: false);
  //         store.gradeDisplay = deserializeGradeDisplay(value);
  //       },
  //     ),
  //     SettingsHeader(
  //       title: context.locale.settings.groupsAdvancedTitle,
  //     ),
  //     ListTile(
  //       title: Text(context.locale.settings.restartAppTitle),
  //       subtitle: Text(context.locale.settings.restartAppSubtitle),
  //       onTap: () async {
  //         RestartWidget.restartApp(context);
  //       },
  //     ),
  //     if (kDebugMode) ...[
  //       SettingsHeader(
  //         title: "[DEBUG] Danger zone",
  //         subtitle: "[DEBUG] Non usare questi tasti a meno che tu "
  //             "non sappia cosa stai facendo",
  //       ),
  //       ListTile(
  //         title: Text("[DEBUG] Cancella tutte le impostazioni"),
  //         subtitle: Text("Non potrai più recuperare i dati una volta toccato "
  //             "questo pulsante."),
  //         onTap: () async {
  //           final prefs = await SharedPreferences.getInstance();
  //           await prefs.clear();
  //           Navigator.popUntil(context, (route) => route.isFirst);
  //           Navigator.pushReplacementNamed(context, "loading");
  //         },
  //       ),
  //     ],
  //     SizedBox(height: 8),
  //   ];
  //   return Scaffold(
  //     appBar: GradientAppBar(
  //       title: Text(context.locale.settings.title),
  //     ),
  //     body: ListView.builder(
  //       // shrinkWrap: true,
  //       itemCount: children.length,
  //       itemBuilder: (BuildContext context, int index) {
  //         return children[index];
  //       },
  //     ),
  //   );
  // }
}
