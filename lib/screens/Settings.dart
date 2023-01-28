import 'package:flutter/foundation.dart' as Foundation;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reaxios/components/LowLevel/RestartWidget.dart';
import 'package:reaxios/screens/settings/Data.dart';
import 'package:reaxios/screens/settings/Time.dart';
import 'package:reaxios/screens/settings/Update.dart';
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
          context.loc.translate("settings.general"),
          GeneralSettings(),
          Icon(Icons.settings),
        ),
        _Fragment(
          context.loc.translate("settings.time"),
          TimeSettings(),
          Icon(Icons.access_time),
        ),
        _Fragment(
          context.loc.translate("settings.data"),
          DataSettings(),
          Icon(Icons.data_usage),
        ),
        // The web app is updated server-side, so there's no need to
        // alert the user about updates.
        if (!Foundation.kIsWeb)
          _Fragment(
            context.loc.translate("settings.update"),
            UpdateSettings(),
            Icon(Icons.update),
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
            WidgetsBinding.instance.addPostFrameCallback((_) {
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
            appBar: AppBar(
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
    final toolbarHeight = AppBar().toolbarHeight ?? kToolbarHeight;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: Text(context.loc.translate("drawer.settings")),
            centerTitle: true,
          ),
          SliverToBoxAdapter(
            child: SettingsTileGroup(
              children: [
                for (int index = 0; index < _fragments.length; index++)
                  () {
                    final fragment = _fragments[index];
                    return SettingsListTile(
                      leading: fragment.icon,
                      title: Text(fragment.title),
                      subtitle: Text(fragment.body.getDescription(context)),
                      onTap: () => _pushFragment(context, fragment),
                      isThreeLine: true,
                    );
                  }()
              ],
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: 16)),
        ],
      ),
    );
  }
}
