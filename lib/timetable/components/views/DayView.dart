import 'package:flutter/foundation.dart' as Foundation;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reaxios/components/LowLevel/ConditionalChild.dart';
import 'package:reaxios/components/LowLevel/RestartWidget.dart';
import 'package:reaxios/utils/consts.dart';
import 'package:reaxios/utils/format.dart';
import 'package:reaxios/timetable/components/views/DayViewBase.dart';
import 'package:reaxios/timetable/extensions.dart';
import 'package:reaxios/timetable/structures/Settings.dart';
import 'package:reaxios/timetable/structures/Event.dart';
import 'package:reaxios/timetable/structures/Weekday.dart';
import 'package:reaxios/utils/utils.dart';

import '../../../components/LowLevel/MaybeMasterDetail.dart';

class DayView extends StatefulWidget {
  DayView(
    this.events, {
    Key? key,
    required this.fab,
    required this.actions,
    required this.massEdit,
    required this.openMainDrawer,
    required this.rail,
  }) : super(key: key);

  final List<Event> events;
  final FloatingActionButton? fab;
  final Map<String, Function(Event)> actions;
  final Function massEdit;
  final void Function() openMainDrawer;
  final Widget rail;

  @override
  _DayViewState createState() => _DayViewState();
}

class _DayViewState extends State<DayView> with TickerProviderStateMixin {
  late TabController controller = TabController(
    initialIndex: 0,
    vsync: this,
    length: getSettings(context).getEnabledDays().length *
        getSettings(context).getWeeks(),
  );
  late Map<int, ScrollController> verticalScrollControllers =
      (getSettings(context).getEnabledDays() * getSettings(context).getWeeks())
          .fold(
    Map<int, ScrollController>(),
    (map, element) {
      map.putIfAbsent(element, () => ScrollController(keepScrollOffset: true));
      return map;
    },
  );

  Settings getSettings(BuildContext context) =>
      Provider.of<Settings>(context, listen: false);

  @override
  void initState() {
    super.initState();
    try {
      getSettings(context).addListener(_handleChange);
    } catch (e) {
      // shut up I don't care
    }
  }

  @override
  void dispose() {
    try {
      getSettings(context).removeListener(_handleChange);
    } catch (e) {
      // shut up I don't care
    }
    super.dispose();
  }

  _handleChange() {
    if (mounted)
      setState(() {
        controller = TabController(
          initialIndex: 0,
          vsync: this,
          length: getSettings(context).getEnabledDays().length *
              getSettings(context).getWeeks(),
        );
      });
  }

  List<Event> get events => widget.events;

  List<PopupMenuEntry<String>> getPopupItems(
    BuildContext context,
    Settings settings,
  ) {
    return [
      if (events.isNotEmpty) ...[
        PopupMenuItem<String>(
          onTap: () async {
            // Required to be able to show the dialog
            // after the pop up menu has been closed
            WidgetsBinding.instance.addPostFrameCallback((_) {
              widget.massEdit();
            });
          },
          // child: Text("Edit multiple events"),
          child: Text(context.loc.translate("timetable.editMultiple")),
        ),
        PopupMenuDivider(),
      ],
      PopupMenuItem<String>(
        onTap: () {
          settings.share(["events"]);
        },
        // child: Text("Export"),
        child: Text(context.loc.translate("timetable.export")),
      ),
      PopupMenuItem<String>(
        onTap: () async {
          try {
            await settings.load();
            RestartWidget.restartApp(context);
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  context.loc.translate("timetable.importFailed"),
                  style: TextStyle(color: Colors.white),
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Text(context.loc.translate("timetable.import")),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Provider.of<Settings>(context, listen: false),
      builder: (context, _) => Builder(builder: (context) {
        final settings = Provider.of<Settings>(context);
        return Scaffold(
          appBar: AppBar(
            notificationPredicate: (notification) {
              return notification.depth == 1;
            },
            title: Text(context.loc.translate("timetable.dayView")),
            bottom: TabBar(
              isScrollable: true,
              controller: controller,
              tabs: (settings.getEnabledDays() * settings.getWeeks())
                  .entries
                  .entries
                  .map((entry) {
                final day = Weekday.get(entry.value, 1)
                    .toLongString(context.currentLocale.languageCode);
                String week = "";
                if (settings.getWeeks() > 1) {
                  week = context.loc.translate("timetable.dayViewWeek").format([
                    ((entry.key + 2) / 7).floor() + 1,
                  ]);
                }
                return Tab(text: "$day$week");
              }).toList(),
              dividerColor: Colors.transparent,
            ),
            leading: MaybeMasterDetail.of(context)!.isShowingMaster
                ? null
                : IconButton(
                    icon: Icon(Icons.menu),
                    onPressed: widget.openMainDrawer,
                  ),
            actions: [
              if (Foundation.kDebugMode)
                IconButton(
                  onPressed: () => RestartWidget.restartApp(context),
                  icon: Icon(Icons.refresh),
                  tooltip: "[DEBUG] Restart app",
                ),
              if (getPopupItems(context, settings).isNotEmpty)
                Builder(
                  builder: (context) => PopupMenuButton<String>(
                    onSelected: print,
                    itemBuilder: (_) {
                      return getPopupItems(context, settings);
                    },
                  ),
                ),
            ],
          ),
          body: Row(
            children: [
              widget.rail,
              ConditionalChild(
                child: VerticalDivider(
                  thickness: 1,
                  width: 1,
                ),
                show: MaybeMasterDetail.of(context)!.detailWidth >=
                    kTabBreakpoint,
              ),
              Expanded(
                child: Center(
                  child: TabBarView(
                    controller: controller,
                    children: (getSettings(context).getEnabledDays() *
                            getSettings(context).getWeeks())
                        .entries
                        .entries
                        .map((entry) {
                      final wdi = entry.value;
                      final week = ((entry.key + 2) / 7).floor() + 1;
                      var dayEvents = events.where((element) {
                        return element.weekday.value == wdi &&
                            element.weekday.week == week;
                      }).toList();

                      if (dayEvents.isEmpty) return emptyDay();

                      return SingleChildScrollView(
                        controller: verticalScrollControllers[wdi],
                        child: DayViewBase(
                          events: dayEvents,
                          showDayHeader: false,
                          actions: widget.actions,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget emptyDay() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Icon(
              Icons.access_time,
              size: 64,
              color: Theme.of(context).textTheme.caption!.color,
            ),
          ),
          Text(context.loc.translate("timetable.emptyDay"),
              style: Theme.of(context).textTheme.caption),
        ],
      ),
    );
  }
}
