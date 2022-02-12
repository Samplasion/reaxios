import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reaxios/format.dart';
import 'package:reaxios/timetable/components/essential/DayViewText.dart';
import 'package:reaxios/timetable/components/essential/GradientAppBar.dart';
import 'package:reaxios/timetable/components/essential/EventWeekView.dart';
import 'package:reaxios/timetable/extensions.dart';
import 'package:reaxios/timetable/structures/Settings.dart';
import 'package:reaxios/timetable/structures/Event.dart';
import 'package:reaxios/timetable/structures/Weekday.dart';
import 'package:reaxios/timetable/utils.dart';
import 'package:reaxios/utils.dart';

import '../../../components/LowLevel/ConditionalChild.dart';
import '../../../components/LowLevel/MaybeMasterDetail.dart';
import '../../../consts.dart';
import '../../../tuple.dart';

class WeekView extends StatefulWidget {
  WeekView(
    this.events, {
    Key? key,
    required this.fab,
    required this.actions,
    required this.openMainDrawer,
    required this.rail,
  }) : super(key: key);

  final List<Event> events;
  final FloatingActionButton? fab;
  final Map<String, Function(Event)> actions;
  final void Function() openMainDrawer;
  final Widget rail;

  @override
  _WeekViewState createState() => _WeekViewState();
}

class _WeekViewState extends State<WeekView>
    with SingleTickerProviderStateMixin {
  late ScrollController controller;
  bool editingMode = false;
  Event? editing;

  late TabController tabController = TabController(
    initialIndex: 0,
    vsync: this,
    length: settings.getWeeks(),
  );

  Settings get settings => Provider.of<Settings>(context, listen: false);

  @override
  void initState() {
    super.initState();

    controller = ScrollController();
  }

  List<Event> get events => widget.events;
  @override
  Widget build(BuildContext context) {
    final days = settings.getEnabledDays();
    DateTime base = DateTimeUtils.getFirstDayOfWeek();

    return Scaffold(
      appBar: getAppBar(),
      body: Row(
        children: [
          widget.rail,
          ConditionalChild(
            child: VerticalDivider(
              thickness: 1,
              width: 1,
            ),
            show: MaybeMasterDetail.of(context)!.detailWidth >= kTabBreakpoint,
          ),
          Expanded(
            child: TabBarView(
              controller: tabController,
              children: 1.to(settings.getWeeks()).map((week) {
                return SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: days.map((wdi) {
                      var dayEvents = events
                          .where((element) =>
                              element.weekday.value == wdi &&
                              element.weekday.week == week)
                          .toList();

                      // These values are good enough for compensating for the hour
                      // column.
                      // When resizing, the texts are collapsed with a margin
                      // of 1 frame.
                      const Map<int, Tuple2<int, int>> flex = {
                        0: Tuple2(1, 1),
                        1: Tuple2(1, 1),
                        2: Tuple2(96, 79),
                        3: Tuple2(96, 79),
                        4: Tuple2(96, 79),
                        5: Tuple2(96, 79),
                        6: Tuple2(96, 79),
                        7: Tuple2(3, 2),
                      };

                      return Flexible(
                        flex: days[0] == wdi
                            ? flex[days.length]!.first
                            : flex[days.length]!.second,
                        child: EventWeekView(
                          day: base.add(Duration(days: (wdi - 1))),
                          showHours: days[0] == wdi,
                          events: dayEvents,
                          onEnterEditingMode: (sub) {
                            setState(() {
                              editing = sub;
                              editingMode = true;
                            });
                          },
                          selectedEvent: editing,
                        ),
                      );
                    }).toList(),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget getAppBar() {
    final tabBar = settings.getWeeks() > 1
        ? TabBar(
            isScrollable: true,
            controller: tabController,
            indicatorColor: Theme.of(context).colorScheme.onPrimary,
            tabs: 1.to(settings.getWeeks()).map((week) {
              return Tab(
                text: context.locale.timetable.weekViewWeek.format([week]),
              );
            }).toList(),
          )
        : null;
    final defaultAppBar = GradientAppBar(
      title: Text(context.locale.timetable.weekView),
      bottom: tabBar,
      leading: MaybeMasterDetail.of(context)!.isShowingMaster
          ? null
          : IconButton(
              icon: Icon(Icons.menu),
              onPressed: widget.openMainDrawer,
            ),
    );
    return PreferredSize(
      child: Material(
        child: AnimatedCrossFade(
          firstChild: defaultAppBar,
          secondChild: GradientAppBar(
            title: Text(editing?.name ?? ""),
            colors: Colors.black.toSlightGradient(),
            foregroundColor: Colors.white,
            leading: IconButton(
              tooltip: context.materialLocale.okButtonLabel,
              onPressed: () {
                setState(() {
                  editing = null;
                  editingMode = false;
                });
              },
              icon: Icon(Icons.done),
            ),
            actions: [
              IconButton(
                tooltip: context.locale.timetable.actionsEdit,
                onPressed: () {
                  widget.actions["Edit"]!(editing!);
                  // Quit editing mode after opening the editor
                  setState(() {
                    editing = null;
                    editingMode = false;
                  });
                },
                icon: Icon(Icons.edit),
              ),
            ],
            bottom: tabBar,
          ),
          crossFadeState: editingMode
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: Duration(milliseconds: 300),
          sizeCurve: Curves.easeInOut,
        ),
        elevation: 4,
      ),
      preferredSize: defaultAppBar.preferredSize,
    );
  }

  Widget emptyDay(Weekday day) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [DayViewText(day.toString())],
      ),
    );
  }
}
