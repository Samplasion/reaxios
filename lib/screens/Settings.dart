import 'package:flutter/foundation.dart' as Foundation;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reaxios/components/LowLevel/GradientAppBar.dart';
import 'package:reaxios/components/LowLevel/RestartWidget.dart';
import 'package:reaxios/screens/settings/Data.dart';
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
          context.locale.settings.general,
          GeneralSettings(),
          Icon(Icons.settings),
        ),
        _Fragment(
          context.locale.settings.time,
          TimeSettings(),
          Icon(Icons.access_time),
        ),
        _Fragment(
          context.locale.settings.data,
          DataSettings(),
          Icon(Icons.data_usage),
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
    final toolbarHeight = AppBar().toolbarHeight ?? kToolbarHeight;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            floating: false,
            delegate: CustomSliverDelegate(
              hideTitleWhenExpanded: true,
              expandedHeight: MediaQuery.of(context).padding.top + 185,
              collapsedHeight:
                  MediaQuery.of(context).padding.top + toolbarHeight,
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final fragment = _fragments[index];
                return ListTile(
                  leading: fragment.icon,
                  title: Text(fragment.title),
                  subtitle: Text(fragment.body.getDescription(context)),
                  onTap: () => _pushFragment(context, fragment),
                  isThreeLine: true,
                );
              },
              childCount: _fragments.length,
            ),
          ),
        ],
      ),
    );
  }
}

class CustomSliverDelegate extends SliverPersistentHeaderDelegate {
  final double collapsedHeight;
  final double expandedHeight;
  final bool hideTitleWhenExpanded;

  CustomSliverDelegate({
    required this.collapsedHeight,
    required this.expandedHeight,
    this.hideTitleWhenExpanded = true,
  });

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final appBarSize = (expandedHeight - shrinkOffset);
    final proportion = 2 - (expandedHeight / appBarSize);
    final percent = proportion < 0 || proportion > 1 ? 0.0 : proportion;
    return SizedBox(
      height: expandedHeight + expandedHeight / 2,
      // height: appBarSize,
      child: Stack(
        children: [
          SizedBox(
            height: appBarSize < collapsedHeight ? collapsedHeight : appBarSize,
            child: GradientAppBar(
              elevation: map(percent, 0, 1, 4, 0).toDouble(),
              title: Opacity(
                opacity: hideTitleWhenExpanded ? 1.0 - percent : 1.0,
                child: Text(context.locale.drawer.settings),
              ),
            ),
          ),
          Positioned(
            left: 0.0,
            right: 0.0,
            bottom: 16,
            child: Opacity(
              opacity: percent,
              child: Text(
                context.locale.drawer.settings,
                style: Theme.of(context).textTheme.headline5!.copyWith(
                      color: Theme.of(context).colorScheme.primary.contrastText,
                    ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  // double get maxExtent => expandedHeight + expandedHeight / 2;
  double get maxExtent => expandedHeight;

  @override
  double get minExtent => collapsedHeight;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
