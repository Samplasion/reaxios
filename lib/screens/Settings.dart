import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart' as S;
import 'package:provider/provider.dart';
import 'package:reaxios/components/LowLevel/GradientAppBar.dart';
import 'package:reaxios/components/LowLevel/RestartWidget.dart';
import 'package:reaxios/enums/GradeDisplay.dart';
import 'package:reaxios/system/Store.dart';
import 'package:reaxios/utils.dart';
import 'package:settings_ui/settings_ui.dart';
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
      S.SettingsGroup(
        title: context.locale.settings.groupsColorsTitle,
        subtitle: context.locale.settings.changesRestart,
        children: <Widget>[
          S.ColorPickerSettingsTile(
            settingKey: 'accent-color',
            title: context.locale.settings.colorPrimary,
            defaultValue: Theme.of(context).accentColor,
          ),
          S.ColorPickerSettingsTile(
            settingKey: 'primary-color',
            title: context.locale.settings.colorSecondary,
            defaultValue: Theme.of(context).primaryColor,
          ),
          S.RadioModalSettingsTile(
            settingKey: 'theme-mode',
            title: context.locale.settings.colorTheme,
            selected: 'dynamic',
            values: {
              "light": context.locale.settings.colorThemeLight,
              "dark": context.locale.settings.colorThemeDark,
              "dynamic": context.locale.settings.colorThemeDynamic,
            },
            onChange: (_) => Navigator.pop(context),
          ),
        ],
      ),
      S.SettingsGroup(
        title: context.locale.settings.groupsBehaviorTitle,
        children: <Widget>[
          S.RadioModalSettingsTile(
            settingKey: 'grade-display',
            title: context.locale.settings.gradeDisplayLabel,
            selected: GradeDisplay.decimal.serialized,
            values: {
              GradeDisplay.decimal.serialized:
                  context.locale.settings.gradeDisplayDecimal,
              GradeDisplay.letter.serialized:
                  context.locale.settings.gradeDisplayLetter,
              GradeDisplay.percentage.serialized:
                  context.locale.settings.gradeDisplayPercentage,
            },
            onChange: (String value) {
              final store = Provider.of<RegistroStore>(context, listen: false);
              store.gradeDisplay = deserializeGradeDisplay(value);
              Navigator.pop(context);
            },
          ),
        ],
      ),
      S.SettingsGroup(
        title: context.locale.settings.groupsAdvancedTitle,
        children: <Widget>[
          S.SimpleSettingsTile(
            title: context.locale.settings.restartAppTitle,
            subtitle: context.locale.settings.restartAppSubtitle,
            onTap: () async {
              RestartWidget.restartApp(context);
            },
          )
        ],
      ),
      if (kDebugMode)
        S.SettingsGroup(
          title: "[DEBUG] Danger zone",
          subtitle: "[DEBUG] Non usare questi tasti a meno che tu "
              "non sappia cosa stai facendo",
          children: [
            S.SimpleSettingsTile(
              title: "[DEBUG] Cancella tutte le impostazioni",
              subtitle: "Non potrai più recuperare i dati una volta toccato "
                  "questo pulsante.",
              onTap: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();
                Navigator.popUntil(context, (route) => route.isFirst);
                Navigator.pushReplacementNamed(context, "loading");
              },
            )
          ],
        ),
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

/*
SettingsList(
  backgroundColor: Theme.of(context).canvasColor,
  sections: [
    _AndroidOnlySection(
      // title: 'Section',
      tiles: [
        CustomTile(
          title: 'Language',
          subtitle: 'English',
          leading: Icon(Icons.language),
          onPressed: (BuildContext context) {},
        ),
        CustomTile.switchTile(
          title: 'Use fingerprint',
          leading: Icon(Icons.fingerprint),
          switchValue: _value,
          onToggle: (bool value) {
            setState(() {
              _value = value;
            });
          },
        ),
      ],
    ),
  ],
),
*/
}

enum _SettingsTileType { simple, switchTile }

class CustomTile extends SettingsTile {
  final String title;
  final int? titleMaxLines;
  final String? subtitle;
  final int? subtitleMaxLines;
  final Widget? leading;
  final Widget? trailing;
  final Icon? iosChevron = null;
  final EdgeInsetsGeometry? iosChevronPadding = null;
  final VoidCallback? onTap = null;
  final Function(BuildContext context)? onPressed;
  final Function(bool value)? onToggle;
  final bool? switchValue;
  final bool enabled;
  final TextStyle? titleTextStyle = null;
  final TextStyle? subtitleTextStyle = null;
  final Color? switchActiveColor;
  final _SettingsTileType _tileType;

  const CustomTile(
      {Key? key,
      required this.title,
      this.titleMaxLines,
      this.subtitle,
      this.subtitleMaxLines,
      this.leading,
      this.trailing,
      this.enabled = true,
      this.onPressed,
      this.switchActiveColor,
      this.switchValue})
      : onToggle = null,
        _tileType = _SettingsTileType.simple,
        super(
          key: key,
          title: title,
          subtitle: subtitle,
          titleMaxLines: titleMaxLines,
          subtitleMaxLines: subtitleMaxLines,
          leading: leading,
          trailing: trailing,
          enabled: enabled,
          onPressed: onPressed,
          switchActiveColor: switchActiveColor,
        );

  CustomTile.switchTile({
    Key? key,
    required this.title,
    this.titleMaxLines,
    this.subtitle,
    this.subtitleMaxLines,
    this.leading,
    this.enabled = true,
    this.trailing,
    required this.onToggle,
    required this.switchValue,
    this.switchActiveColor,
  })  : _tileType = _SettingsTileType.switchTile,
        onPressed = null,
        super.switchTile(
          title: title,
          titleMaxLines: titleMaxLines,
          subtitle: subtitle,
          subtitleMaxLines: subtitleMaxLines,
          leading: leading,
          enabled: enabled,
          trailing: trailing,
          switchActiveColor: switchActiveColor,
          switchValue: switchValue,
          subtitleTextStyle: null,
          onToggle: onToggle,
        );

  @override
  Widget build(BuildContext context) {
    return androidTile(context);
  }
}
