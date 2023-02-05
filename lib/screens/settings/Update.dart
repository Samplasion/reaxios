import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:reaxios/components/Views/SubjectObjectivesManagerView.dart';
import 'package:reaxios/enums/UpdateNagMode.dart';
import 'package:reaxios/utils/format.dart';
import 'package:reaxios/timetable/structures/Settings.dart';
import 'package:reaxios/utils/utils.dart';
import 'base.dart';

class UpdateSettings extends BaseSettings {
  const UpdateSettings({Key? key}) : super(key: key);

  @override
  List<SettingsTile> getTiles(BuildContext context, Settings settings, _) {
    return [
      SettingsTileGroup(
        title: SettingsHeader(title: context.loc.translate("settings.update")),
        children: [
          RadioModalTile<UpdateNagMode>(
            title: Text(context.loc.translate("updateSettings.updateNagMode")),
            values: {
              UpdateNagMode.alert:
                  context.loc.translate("updateSettings.updateNagModeAlert"),
              UpdateNagMode.banner:
                  context.loc.translate("updateSettings.updateNagModeBanner"),
              UpdateNagMode.none:
                  context.loc.translate("updateSettings.updateNagModeNone"),
            },
            selectedValue: settings.getUpdateNagMode(),
            onChange: (value) {
              settings.setUpdateNagMode(value);
            },
          ),
        ],
      ),
    ];
  }
}
