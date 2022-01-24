import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reaxios/timetable/components/views/settings/base.dart';
import 'package:reaxios/timetable/structures/Settings.dart';

class TextSettings extends BaseSettings {
  const TextSettings({Key? key}) : super(key: key);

  @override
  List<SettingsTile> getTiles(BuildContext context, Settings settings) => [
        TextFormFieldModalTile(
          title: Text('Ignored words'),
          value: settings.getIgnoreList().join(" "),
          onChange: (ignored) => settings.setIgnoreList(ignored),
        ),
      ];
}
