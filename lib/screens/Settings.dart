import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart' as S;
import 'package:reaxios/components/LowLevel/RestartWidget.dart';
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
    return S.SettingsScreen(
      title: "Impostazioni",
      children: [
        S.SettingsGroup(
          title: 'Colori',
          subtitle: "I cambiamenti verranno applicati al riavvio dell'app.",
          children: <Widget>[
            S.ColorPickerSettingsTile(
              settingKey: 'accent-color',
              title: 'Colore primario',
              defaultValue: Theme.of(context).accentColor,
            ),
            S.ColorPickerSettingsTile(
              settingKey: 'primary-color',
              title: 'Colore secondario',
              defaultValue: Theme.of(context).primaryColor,
            ),
            S.RadioModalSettingsTile(
              settingKey: 'theme-mode',
              title: "Tema",
              selected: 'dynamic',
              values: {
                "light": "Tema chiaro",
                "dark": "Tema scuro",
                "dynamic": "Automatico",
              },
              onChange: (_) => Navigator.pop(context),
            ),
            Divider(height: Theme.of(context).dividerTheme.thickness),
            S.SimpleSettingsTile(
              title: "Riavvia app",
              subtitle: "Applica immediatamente le impostazioni.",
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
      ],
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
