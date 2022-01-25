import 'package:flutter/material.dart';
import 'package:reaxios/timetable/components/essential/DayViewText.dart';
import 'package:reaxios/timetable/components/essential/EventView.dart';
import 'package:reaxios/timetable/structures/Event.dart';
import 'package:reaxios/timetable/utils.dart';

class DayViewBase extends StatelessWidget {
  final List<Event> events;
  final bool expandable;
  final bool showDayHeader;
  final Map<String, Function(Event)> actions;

  const DayViewBase({
    Key? key,
    required this.events,
    this.expandable = true,
    this.showDayHeader = true,
    this.actions = const {},
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (showDayHeader) DayViewText(events[0].weekday.toString()),
          ...(events..sort((s1, s2) => s1.start.inMinutes - s2.start.inMinutes))
              .map(
                (s) => AnimatedCrossFade(
                  firstChild: EventView(
                    s,
                    expandable: expandable,
                    actions: actions,
                    compact: false,
                  ),
                  secondChild: EventView(
                    s,
                    expandable: expandable,
                    actions: actions,
                    compact: true,
                  ),
                  crossFadeState: isSmall(context)
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: Duration(milliseconds: 300),
                  sizeCurve: Curves.easeInOut,
                ),
              )
              .toList(),
        ],
      ),
    );
  }
}
