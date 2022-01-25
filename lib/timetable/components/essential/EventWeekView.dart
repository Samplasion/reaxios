import 'package:flutter/material.dart';
import 'package:flutter_week_view/flutter_week_view.dart';
import 'package:reaxios/timetable/components/essential/EventView.dart';
import 'package:reaxios/timetable/structures/Settings.dart';
import 'package:reaxios/timetable/structures/Event.dart';
import 'package:reaxios/timetable/structures/Weekday.dart';
import 'package:reaxios/timetable/utils.dart';
import 'package:reaxios/utils.dart';

class EventWeekView extends StatefulWidget {
  const EventWeekView({
    Key? key,
    this.showHours = true,
    required this.day,
    required this.events,
    required this.onEnterEditingMode,
    required this.selectedEvent,
  }) : super(key: key);

  final DateTime day;
  final bool showHours;
  final List<Event> events;
  final Function(Event) onEnterEditingMode;
  final Event? selectedEvent;

  @override
  _EventWeekViewState createState() => _EventWeekViewState();
}

class _EventWeekViewState extends State<EventWeekView>
    with WidgetsBindingObserver {
  UniqueKey _resizeKey = UniqueKey();

  @override
  void didChangeMetrics() {
    setState(() {
      _resizeKey = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return KeyedSubtree(
      child: LayoutBuilder(
        builder: (context, _) => DayView(
          inScrollableWidget: false,
          date: widget.day,
          userZoomable: false,
          style: DayViewStyle(
            backgroundColor: theme.canvasColor,
            backgroundRulesColor: theme.textTheme.caption?.color?.withAlpha(80),
            currentTimeRuleColor: theme.primaryColor,
            currentTimeRuleHeight: 2,
          ),
          dayBarStyle:
              DayBarStyle.fromDate(date: Weekday.days[1]![0].toDateTime)
                  .copyWith(
            dateFormatter: (y, m, d) {
              return Weekday.get(DateTime(y, m, d).weekday, 1)
                  .toShortString(context.currentLocale.languageCode)
                  .toUpperCase();
            },
            textStyle: theme.textTheme.caption
                ?.copyWith(overflow: TextOverflow.visible),
            color: theme.cardColor,
          ),
          hoursColumnStyle: HoursColumnStyle(
              color: theme.cardColor,
              textStyle: theme.textTheme.caption,
              width: widget.showHours ? 25 : 0,
              timeFormatter: (hm) {
                return hm.hour.toString();
              }),
          events: widget.events.map((s) {
            return _WeekViewEventBase(
              s,
              widget.day,
              onEnterEditingMode: widget.onEnterEditingMode,
              editing: widget.selectedEvent == s,
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _CustomDayView extends DayView {
  final List<Widget> widgetEvents;

  _CustomDayView({
    bool? inScrollableWidget,
    required DateTime date,
    bool? userZoomable,
    DayViewStyle? style,
    DayBarStyle? dayBarStyle,
    HoursColumnStyle? hoursColumnStyle,
    List<FlutterWeekViewEvent>? events,
    this.widgetEvents = const [],
  }) : super(
          inScrollableWidget: inScrollableWidget,
          date: date,
          userZoomable: userZoomable,
          style: style,
          dayBarStyle: dayBarStyle,
          hoursColumnStyle: hoursColumnStyle,
          events: events,
        );
}

class _WeekViewEventBase extends FlutterWeekViewEvent {
  final Event event;
  final Function(Event) onEnterEditingMode;
  final bool editing;

  _WeekViewEventBase(
    this.event,
    DateTime day, {
    required this.onEnterEditingMode,
    this.editing = false,
  }) : super(
          title: event.name,
          description: event.notes,
          start: event.start.toDateTime(day),
          end: event.end.toDateTime(day),
          backgroundColor: event.color,
          textStyle: TextStyle(
            color: getContrastColor(event.color),
          ),
        );

  @override
  Widget build(
    BuildContext context,
    DayView dayView,
    double height,
    double width,
  ) {
    return EventView(
      event,
      expandable: false,
      maxHeight: height.floorToDouble(),
      maxWidth: width.floorToDouble(),
      compact: true,
      inverted: editing,
      onLongPress: () => onEnterEditingMode(event),
    );
  }
}
