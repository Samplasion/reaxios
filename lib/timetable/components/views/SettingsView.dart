import 'package:flutter/foundation.dart' as Foundation;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'settings/base.dart';
import 'settings/Text.dart';
import 'settings/Time.dart';
import '../essential/GradientAppBar.dart';
import '../essential/RestartWidget.dart';
import '../../structures/Settings.dart';

class SettingsView extends StatefulWidget {
  SettingsView({Key? key}) : super(key: key);

  @override
  _SettingsViewState createState() => _SettingsViewState();
}

class _Fragment {
  final String title;
  final BaseSettings body;

  _Fragment(this.title, this.body);
}

class _SettingsViewState extends State<SettingsView> {
  bool _dirty = true;

  List<_Fragment> get _fragments => [
        _Fragment(
          "Text settings",
          TextSettings(),
        ),
        _Fragment(
          "Time settings",
          TimeSettings(),
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
            RestartWidget.of(context)!.restart();
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
        title: Text('Settings'),
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
      body: ListView(
        children: _fragments.map((fragment) {
          return ListTile(
            title: Text(fragment.title),
            subtitle: Text(fragment.body.getDescription(context)),
            onTap: () => _pushFragment(context, fragment),
          );
        }).toList(),
      ),
    );
  }
}
