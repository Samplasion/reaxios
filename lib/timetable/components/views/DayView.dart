import 'package:flutter/foundation.dart' as Foundation;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reaxios/timetable/components/essential/GradientAppBar.dart';
import 'package:reaxios/timetable/components/essential/RestartWidget.dart';
import 'package:reaxios/timetable/components/views/DayViewBase.dart';
import 'package:reaxios/timetable/components/views/EventEditor.dart';
import 'package:reaxios/timetable/extensions.dart';
import 'package:reaxios/timetable/structures/Settings.dart';
import 'package:reaxios/timetable/structures/Event.dart';
import 'package:reaxios/timetable/structures/Weekday.dart';

class DayView extends StatefulWidget {
  DayView(
    this.events, {
    Key? key,
    required this.fab,
    required this.actions,
    required this.massEdit,
  }) : super(key: key);

  final List<Event> events;
  final FloatingActionButton? fab;
  final Map<String, Function(Event)> actions;
  final Function massEdit;

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

  List<Event> get events => widget.events;

  List<PopupMenuEntry<String>> getPopupItems() {
    return [
      if (events.isNotEmpty)
        PopupMenuItem<String>(
          onTap: () async {
            // Required to be able to show the dialog
            // after the pop up menu has been closed
            WidgetsBinding.instance!.addPostFrameCallback((_) {
              widget.massEdit();
            });
          },
          child: Text("Edit multiple events"),
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      final settings = context.watch<Settings>();
      return Scaffold(
        appBar: GradientAppBar(
          title: Text("Day View"),
          bottom: TabBar(
            isScrollable: true,
            controller: controller,
            indicatorColor: Theme.of(context).colorScheme.onPrimary,
            tabs: (settings.getEnabledDays() * settings.getWeeks())
                .entries
                .entries
                .map((entry) {
              final day = Weekday.get(entry.value, 1).toString();
              String week = "";
              if (settings.getWeeks() > 1) {
                week = " [week ${((entry.key + 2) / 7).floor() + 1}]";
              }
              return Tab(text: "$day$week");
            }).toList(),
          ),
          actions: [
            if (Foundation.kDebugMode)
              IconButton(
                onPressed: () => RestartWidget.of(context)?.restart(),
                icon: Icon(Icons.refresh),
                tooltip: "[DEBUG] Restart app",
              ),
            if (getPopupItems().isNotEmpty)
              PopupMenuButton<String>(
                onSelected: print,
                itemBuilder: (BuildContext context) {
                  return getPopupItems();
                },
              ),
          ],
        ),
        body: Center(
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
        floatingActionButton: widget.fab,
      );
    });
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
              Icons.alarm,
              size: 64,
              color: Theme.of(context).textTheme.caption!.color,
            ),
          ),
          Text("There are no events today.",
              style: Theme.of(context).textTheme.caption),
        ],
      ),
    );
  }
}
