import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:reaxios/components/Views/SubjectObjectivesManagerView.dart';
import 'package:reaxios/enums/UpdateNagMode.dart';
import 'package:reaxios/format.dart';
import 'package:reaxios/timetable/structures/Settings.dart';
import 'package:reaxios/utils.dart';
import 'base.dart';

class UpdateSettings extends BaseSettings {
  const UpdateSettings({Key? key}) : super(key: key);

  @override
  List<SettingsTile> getTiles(BuildContext context, Settings settings) {
    return [
      RadioModalTile<UpdateNagMode>(
        title: Text(context.locale.updateSettings.updateNagMode),
        values: {
          UpdateNagMode.alert: context.locale.updateSettings.updateNagModeAlert,
          UpdateNagMode.banner:
              context.locale.updateSettings.updateNagModeBanner,
          UpdateNagMode.none: context.locale.updateSettings.updateNagModeNone,
        },
        selectedValue: settings.getUpdateNagMode(),
        onChange: (value) {
          settings.setUpdateNagMode(value);
        },
      ),
    ];
  }
}
