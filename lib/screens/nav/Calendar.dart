import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:reaxios/api/Axios.dart';
import 'package:reaxios/api/entities/Assignment/Assignment.dart';
import 'package:reaxios/api/entities/Structural/Structural.dart';
import 'package:reaxios/api/entities/Topic/Topic.dart';
import 'package:reaxios/components/ListItems/AssignmentListItem.dart';
import 'package:reaxios/components/ListItems/TopicListItem.dart';
import 'package:reaxios/components/LowLevel/Empty.dart';
import 'package:reaxios/system/Store.dart';
import 'package:reaxios/tuple.dart';
import 'package:reaxios/utils.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:table_calendar/table_calendar.dart';

// lang: it

class CalendarPane extends StatefulWidget {
  final Axios session;

  CalendarPane({Key? key, required this.session}) : super(key: key);

  @override
  _CalendarPaneState createState() => _CalendarPaneState();
}

class _CalendarPaneState extends State<CalendarPane> {
  @override
  Widget build(BuildContext context) {
    final store = Provider.of<RegistroStore>(context);

    return FutureBuilder<Tuple3<List<Topic>, List<Assignment>, List<Period>>>(
      future: Future.wait([
        store.topics ?? Future.value(<Topic>[]),
        store.assignments ?? Future.value(<Assignment>[]),
        store.periods ?? Future.value(<Period>[]),
      ]).then((it) => Tuple3.fromIterable(it)),
      builder: (BuildContext context,
          AsyncSnapshot<Tuple3<List<Topic>, List<Assignment>, List<Period>>>
              snapshot) {
        if (snapshot.hasError) {
          print(snapshot.error);
          if (snapshot.error is Error) {
            print((snapshot.error as Error?)?.stackTrace);
          }
        }
        if (snapshot.hasData) {
          final topics = snapshot.requireData.first;
          final assignments = snapshot.requireData.second;
          final periods = snapshot.requireData.third;

          periods.sort((p1, p2) => p1.startDate.compareTo(p2.startDate));

          return buildOk(context, topics, assignments, periods);
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  List<Widget>? _events;

  Widget buildOk(BuildContext context, List<Topic> topics,
      List<Assignment> assignments, List<Period> periods) {
    if (_events == null) {
      _events = _getEvents(topics, assignments, periods, _selectedDay);
    }
    final emptyDays = [1, 2, 3, 4, 5, 6, 7]..removeWhere((wd) {
        return topics.any((element) => element.date.weekday == wd) ||
            assignments.any((element) => element.date.weekday == wd);
      });
    return Container(
      child: Column(
        children: <Widget>[
          TableCalendar(
            firstDay: periods.first.startDate,
            lastDay: periods.last.endDate,
            focusedDay: _focusedDay,
            selectedDayPredicate: (DateTime date) =>
                _selectedDay.isSameDay(date),
            onDaySelected: (selected, focused) {
              setState(() {
                _focusedDay = focused;
                _selectedDay = selected;
                _events = _getEvents(topics, assignments, periods, selected);
              });
            },
            calendarFormat: _calendarFormat,
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            eventLoader: (date) => _getEvents(
              topics,
              assignments,
              periods,
              date,
            ),
            locale: "it_IT",
            weekendDays: [
              if (emptyDays.contains(6)) DateTime.saturday,
              DateTime.sunday
            ],
            startingDayOfWeek: StartingDayOfWeek.monday,
            // Invert the labels so that the button shows the current state
            availableCalendarFormats: {
              CalendarFormat.month: "2 settimane",
              CalendarFormat.twoWeeks: "mese",
            },
            formatAnimationCurve: Curves.easeInOut,
            formatAnimationDuration: Duration(milliseconds: 300),
            pageAnimationCurve: Curves.easeInOut,
            pageAnimationDuration: Duration(milliseconds: 300),
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                // ignore: deprecated_member_use
                final accent = Theme.of(context).accentColor;
                final filtered = events.where(
                    (e) => e is TopicListItem || e is AssignmentListItem);
                if (filtered.length > 0) {
                  return filtered
                      .take(4)
                      .map((e) => CircleAvatar(
                            radius: 3,
                            backgroundColor: accent,
                          ).padding(right: 2, bottom: 2))
                      .toList()
                      .toRow(mainAxisAlignment: MainAxisAlignment.center);
                  // return Container(
                  //   child: Container(
                  //     decoration: BoxDecoration(
                  //       color: accent,
                  //       borderRadius: BorderRadius.circular(2),
                  //     ),
                  //     padding: EdgeInsets.all(2),
                  //     child: Text(
                  //       length.toString(),
                  //       style: TextStyle(
                  //         color: accent.contrastText,
                  //         fontSize: 10,
                  //       ),
                  //     ),
                  //   ),
                  //   alignment: Alignment.bottomCenter,
                  //   padding: EdgeInsets.only(left: 24),
                  // );
                } else {
                  return Container();
                }
              },
              dowBuilder: (context, dayOfWeek) {
                return Container(
                  child: Text(
                    DateFormat.E("it_IT").format(dayOfWeek),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: emptyDays.contains(dayOfWeek.weekday) &&
                              dayOfWeek.weekday > 5
                          ? Colors.red[Utils.getContrastShade(context)]
                          : null,
                    ),
                  ),
                  alignment: Alignment.center,
                );
              },
              todayBuilder: (context, date, focusedDay) {
                final bg = Theme.of(context)
                    .primaryColor
                    .lighten(date == focusedDay ? 0 : 0.2);
                return Container(
                  child: CircleAvatar(
                    backgroundColor: bg,
                    foregroundColor: bg.contrastText,
                    child: Text(
                      date.day.toString(),
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                  alignment: Alignment.center,
                );
              },
              defaultBuilder: (context, date, focusedDay) {
                final fg = Theme.of(context).textTheme.bodyText1!.color!;
                final caption = Theme.of(context).textTheme.caption!.color!;
                return Container(
                  child: CircleAvatar(
                    backgroundColor: Colors.transparent,
                    foregroundColor:
                        emptyDays.contains(date.weekday) ? caption : fg,
                    child: Text(
                      date.day.toString(),
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                  alignment: Alignment.center,
                );
              },
              selectedBuilder: (context, date, focusedDay) {
                final bg = Theme.of(context).primaryColor;
                return Container(
                  child: CircleAvatar(
                    backgroundColor: bg,
                    foregroundColor: bg.contrastText,
                    child: Text(
                      date.day.toString(),
                      style: TextStyle(
                        fontSize: 13,
                        color: bg.contrastText,
                      ),
                    ),
                  ),
                  alignment: Alignment.center,
                );
              },
              outsideBuilder: (context, date, focusedDay) {
                return Container(
                  child: CircleAvatar(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Theme.of(context).disabledColor,
                    child: Text(
                      date.day.toString(),
                      style: TextStyle(
                        fontSize: 13,
                      ),
                    ),
                  ),
                  alignment: Alignment.center,
                );
              },
            ),
          ),
          const SizedBox(height: 16.0),
          Divider(height: 0, indent: 8, endIndent: 8),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemBuilder: (context, index) => _events![index],
              itemCount: _events!.length,
            ).paddingDirectional(top: 16, bottom: 8).scrollable(),
          ),
        ],
      ),
    );
  }

  List<Widget> _getEvents(List<Topic> topics, List<Assignment> assignments,
      List<Period> periods, DateTime date) {
    final events = <Widget>[];

    final todaysAssignments =
        assignments.where((a) => a.date.isSameDay(date)).toList();
    final todaysTopics = topics.where((t) => t.date.isSameDay(date)).toList();

    todaysAssignments.sort((a1, a2) => a1.lessonHour.compareTo(a2.lessonHour));
    todaysTopics.sort((t1, t2) => t1.lessonHour.compareTo(t2.lessonHour));

    if (todaysAssignments.isNotEmpty) {
      events.add(
        Text(
          "Compiti",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ).padding(horizontal: 16),
      );
      events.addAll(
        todaysAssignments.map((a) => AssignmentListItem(assignment: a)),
      );
    }

    if (todaysTopics.isNotEmpty) {
      events.add(
        Text(
          "Argomenti",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ).padding(horizontal: 16, top: events.isNotEmpty ? 16 : 0),
      );
      events.addAll(
        todaysTopics.map((t) => TopicListItem(topic: t)),
      );
    }

    if (events.isEmpty) {
      events.add(
        EmptyUI(
          text: "Nessun evento",
          icon: Icons.event_note,
        ),
      );
    }

    return events.toList();
  }
}
