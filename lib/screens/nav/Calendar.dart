import 'dart:math';

import 'package:animations/animations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:reaxios/api/Axios.dart';
import 'package:reaxios/api/entities/Assignment/Assignment.dart';
import 'package:reaxios/api/entities/Structural/Structural.dart';
import 'package:reaxios/api/entities/Topic/Topic.dart';
import 'package:reaxios/components/ListItems/AssignmentListItem.dart';
import 'package:reaxios/components/ListItems/TopicListItem.dart';
import 'package:reaxios/components/LowLevel/Empty.dart';
import 'package:reaxios/components/LowLevel/GradientAppBar.dart';
import 'package:reaxios/components/LowLevel/GradientCircleAvatar.dart';
import 'package:reaxios/components/LowLevel/MaybeMasterDetail.dart';
import 'package:reaxios/components/Utilities/CardListItem.dart';
import 'package:reaxios/components/Utilities/MaxWidthContainer.dart';
import 'package:reaxios/components/Views/new_calendar_event.dart';
import 'package:reaxios/cubit/app_cubit.dart';
import 'package:reaxios/screens/Index.dart';
import 'package:reaxios/structs/calendar_event.dart';
import 'package:reaxios/timetable/extensions.dart'
    show ColorExtension, RangeExtension;
import 'package:reaxios/timetable/structures/Settings.dart';
import 'package:reaxios/tuple.dart';
import 'package:reaxios/utils.dart' hide ColorUtils;
import 'package:styled_widget/styled_widget.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../components/LowLevel/RestartWidget.dart';

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
    final cubit = context.watch<AppCubit>();
    return BlocBuilder<AppCubit, AppState>(
      bloc: cubit,
      builder: (BuildContext context, AppState state) {
        if (state.structural != null) {
          final periods = cubit.periods;

          periods.sort((p1, p2) => p1.startDate.compareTo(p2.startDate));

          return buildOk(context, periods);
        } else {
          return Scaffold(
            appBar: getDefaultAppBar(context, [], [], [], false),
            body: Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }

  List<PopupMenuEntry<String>> getPopupItems(
    BuildContext context,
    List<Topic> topics,
    List<Assignment> assignments,
    Settings settings,
    List<Period> periods,
  ) {
    // TODO: Copy l10n strings to the calendar group
    return [
      PopupMenuItem<String>(
        onTap: () {
          settings.share(["calendarEvents"], "customEvents.json");
        },
        // child: Text("Export"),
        child: Text(context.locale.timetable.export),
      ),
      PopupMenuItem<String>(
        onTap: () async {
          try {
            await settings.load();
            RestartWidget.restartApp(context);
            _rebuildEvents(context, topics, assignments, periods, _selectedDay);
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  context.locale.timetable.importFailed,
                  style: TextStyle(color: Colors.white),
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Text(context.locale.timetable.import),
      ),
    ];
  }

  DateTime _previouslyFocusedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  CalendarFormat _underlyingCalendarFormat = CalendarFormat.month;
  List<Widget>? _events;
  ScrollController _scrollController = ScrollController();

  CalendarFormat get _calendarFormat {
    final orientation = MediaQuery.of(context).orientation;

    if (orientation == Orientation.landscape) {
      if (_underlyingCalendarFormat == CalendarFormat.month) {
        return CalendarFormat.twoWeeks;
      } else {
        return _underlyingCalendarFormat;
      }
    } else {
      if (_underlyingCalendarFormat == CalendarFormat.week) {
        return CalendarFormat.twoWeeks;
      } else {
        return _underlyingCalendarFormat;
      }
    }
  }

  // Returns the string matching the current state,
  // rather than the future state.
  Map<CalendarFormat, String> get _calendarFormatMap {
    final orientation = MediaQuery.of(context).orientation;

    if (orientation == Orientation.landscape) {
      return {
        CalendarFormat.twoWeeks: context.locale.calendar.formatWeek,
        CalendarFormat.week: context.locale.calendar.formatTwoWeeks,
      };
    } else {
      return {
        CalendarFormat.month: context.locale.calendar.formatTwoWeeks,
        CalendarFormat.twoWeeks: context.locale.calendar.formatMonth,
      };
    }
  }

  GradientAppBar getDefaultAppBar(BuildContext context, List<Topic> topics,
      List<Assignment> assignments, List<Period> periods,
      [bool showMenu = true]) {
    final settings = Provider.of<Settings>(context, listen: false);
    final isShowingMaster = MaybeMasterDetail.of(context)!.isShowingMaster;
    return GradientAppBar(
      title: Text(
        context.locale.drawer.calendar,
      ),
      leading: isShowingMaster
          ? null
          : IconButton(
              icon: Icon(Icons.menu),
              onPressed: () {
                HomeScreen.of(context)!.openDrawer(context);
              },
            ),
      actions: [
        PopupMenuButton(
            itemBuilder: (context) =>
                getPopupItems(context, topics, assignments, settings, periods))
      ],
    );
  }

  GradientAppBar getEditingAppBar(
      List<Topic> topics, List<Assignment> assignments, List<Period> periods) {
    return GradientAppBar(
      title: Text(
        context.locale.drawer.calendar,
      ),
      colors: Colors.black.toSlightGradient(),
      leading: IconButton(
        icon: Icon(Icons.check),
        onPressed: () => _unselectEvent(topics, assignments, periods),
        tooltip: context.locale.calendar.done,
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.edit),
          onPressed: () async {
            final settings = Provider.of<Settings>(context, listen: false);
            CustomCalendarEvent? event =
                await Navigator.push<CustomCalendarEvent>(
              context,
              MaterialPageRoute(
                builder: (context) => CalendarEventEditorView(
                  baseEvent: _selectedEvent,
                  selectedDate: _focusedDay,
                  firstDate: periods.first.startDate,
                  lastDate: periods.last.endDate,
                  selectableDayPredicate: (date) {
                    // Ignore the days that fall outside period
                    // boundaries (e.g. holidays)
                    // Note that days that are not part of the
                    // schoolyear are ignored by the
                    // firstDate/lastDate properties above
                    return periods.any((period) {
                      return date.isAfter(period.startDate) &&
                          date.isBefore(period.endDate);
                    });
                  },
                ),
              ),
            );

            if (event != null) {
              setState(() {
                settings.setCalendarEvents([
                  ...settings
                      .getCalendarEvents()
                      .where((evt) => evt != _selectedEvent),
                  event,
                ]);
              });
              _unselectEvent(topics, assignments, periods);
            }
          },
          tooltip: context.locale.calendar.edit,
        ),
        IconButton(
          icon: Icon(Icons.delete),
          onPressed: () {
            final settings = Provider.of<Settings>(context, listen: false);
            setState(() {
              settings.setCalendarEvents(
                settings
                    .getCalendarEvents()
                    .where((evt) => evt != _selectedEvent)
                    .toList(),
              );
            });
            _unselectEvent(topics, assignments, periods);
          },
          tooltip: context.materialLocale.deleteButtonTooltip,
        ),
      ],
    );
  }

  _unselectEvent(
      List<Topic> topics, List<Assignment> assignments, List<Period> periods) {
    setState(() {
      _editing = false;
      _selectedEvent = null;
    });
    SchedulerBinding.instance!.addPostFrameCallback((_) {
      _rebuildEvents(
        context,
        topics,
        assignments,
        periods,
        _selectedDay,
      );
    });
  }

  CustomCalendarEvent? _selectedEvent;

  bool _editing = false;
  CrossFadeState get _editingState {
    if (_editing && _selectedEvent != null) {
      return CrossFadeState.showSecond;
    } else {
      return CrossFadeState.showFirst;
    }
  }

  Widget buildOk(BuildContext context, List<Period> periods) {
    final cubit = context.watch<AppCubit>();
    final assignments = cubit.assignments;
    final topics = cubit.topics;
    final settings = Provider.of<Settings>(context);
    if (_events == null) {
      _events = _getEvents(
        topics,
        assignments,
        periods,
        settings.getCalendarEvents(),
        _selectedDay,
      );
    }
    final emptyDays = [1, 2, 3, 4, 5, 6, 7]..removeWhere((wd) {
        return topics.any((element) => element.date.weekday == wd) ||
            assignments.any((element) => element.date.weekday == wd);
      });
    return RestartWidget(
      child: Builder(builder: (context) {
        return Scaffold(
          appBar: _editing
              ? getEditingAppBar(topics, assignments, periods)
              : getDefaultAppBar(context, topics, assignments, periods),
          body: Container(
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
                      _previouslyFocusedDay = _focusedDay;
                      _focusedDay = focused;
                      _selectedDay = selected;
                      _events = _getEvents(
                        topics,
                        assignments,
                        periods,
                        settings.getCalendarEvents(),
                        selected,
                      );
                    });
                    _unselectEvent(topics, assignments, periods);
                    _rebuildEvents(
                      context,
                      topics,
                      assignments,
                      periods,
                      selected,
                    );
                  },
                  calendarFormat: _calendarFormat,
                  onFormatChanged: (format) {
                    setState(() {
                      _underlyingCalendarFormat = format;
                    });
                  },
                  onPageChanged: (focusedDay) {
                    _previouslyFocusedDay = _focusedDay;
                    _focusedDay = focusedDay;
                  },
                  eventLoader: (date) => _getEvents(
                    topics,
                    assignments,
                    periods,
                    settings.getCalendarEvents(),
                    date,
                  ),
                  locale: context.currentLocale.toLanguageTag(),
                  weekendDays: [
                    if (emptyDays.contains(6)) DateTime.saturday,
                    DateTime.sunday
                  ],
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  // Invert the labels so that the button shows the current state
                  availableCalendarFormats: _calendarFormatMap,
                  formatAnimationCurve: Curves.easeInOut,
                  formatAnimationDuration: Duration(milliseconds: 300),
                  pageAnimationCurve: Curves.easeInOut,
                  pageAnimationDuration: Duration(milliseconds: 300),
                  calendarBuilders: CalendarBuilders(
                    headerTitleBuilder: (context, day) {
                      return Text(
                        DateFormat.yMMMM(context.currentLocale.toLanguageTag())
                            .format(day),
                        style: TextStyle(
                          fontFamily:
                              Theme.of(context).textTheme.headline6!.fontFamily,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                    markerBuilder: (context, date, events) {
                      final accent = Theme.of(context).colorScheme.secondary;
                      // TODO: Fix this hot mess
                      final filtered = events.where((e) {
                        return e is GenericEventWidget &&
                            (e.type == EventType.topic ||
                                e.type == EventType.assignment);
                      });
                      // Casting with cast<T>() is required because the
                      // usual cast with `as T` doesn't work for some reason
                      final custom = events.where((e) {
                        return e is GenericEventWidget &&
                            e.type == EventType.custom;
                      }).cast<CustomEventWidget>();
                      if (filtered.length > 0) {
                        print(custom.isEmpty ? null : custom.last.runtimeType);
                        return Padding(
                          padding: const EdgeInsets.only(left: 2),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ...filtered.take(4).map(
                                    (e) => CircleAvatar(
                                      radius: 3,
                                      backgroundColor: accent,
                                    ).padding(right: 2, bottom: 2),
                                  ),
                              if (custom.isNotEmpty)
                                ...0
                                    .to(
                                  min(
                                    custom.length - 1,
                                    max(0, 3 - filtered.length),
                                  ),
                                )
                                    .map(
                                  (i) {
                                    return CircleAvatar(
                                      radius: 3,
                                      backgroundColor:
                                          custom.toList()[i].data.color,
                                    ).padding(right: 2, bottom: 2);
                                  },
                                ),
                            ],
                          ),
                        );
                      } else {
                        return Container();
                      }
                    },
                    dowBuilder: (context, dayOfWeek) {
                      return Container(
                        child: Text(
                          DateFormat.E(context.currentLocale.toLanguageTag())
                              .format(dayOfWeek),
                          style: TextStyle(
                            fontFamily: Theme.of(context)
                                .textTheme
                                .headline6!
                                .fontFamily,
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
                          foregroundColor: bg.contrastColor,
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
                      final caption =
                          Theme.of(context).textTheme.caption!.color!;
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
                          foregroundColor: bg.contrastColor,
                          child: Text(
                            date.day.toString(),
                            style: TextStyle(
                              fontSize: 13,
                              color: bg.contrastColor,
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
                  child: PageTransitionSwitcher(
                    reverse: _previouslyFocusedDay.isAfter(_focusedDay),
                    transitionBuilder: (child, animation, secondaryAnimation) {
                      if (kIsWeb) {
                        return FadeTransition(
                          opacity: animation,
                          child: child,
                        );
                      }

                      return SharedAxisTransition(
                        child: child,
                        animation: animation,
                        secondaryAnimation: secondaryAnimation,
                        transitionType: SharedAxisTransitionType.horizontal,
                      );
                    },
                    child: ListView(
                      key: ValueKey(_focusedDay),
                      controller: _scrollController,
                      children: [
                        ..._events!.map(
                          (e) {
                            return MaxWidthContainer(child: e).center();
                          },
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            onPressed: () async {
              CustomCalendarEvent? event =
                  await Navigator.push<CustomCalendarEvent>(
                context,
                MaterialPageRoute(
                  builder: (context) => CalendarEventEditorView(
                    selectedDate: _focusedDay,
                    firstDate: periods.first.startDate,
                    lastDate: periods.last.endDate,
                    selectableDayPredicate: (date) {
                      // Ignore the days that fall outside period
                      // boundaries (e.g. holidays)
                      // Note that days that are not part of the
                      // schoolyear are ignored by the
                      // firstDate/lastDate properties above
                      return periods.any((period) {
                        return date.isAfter(period.startDate) &&
                            date.isBefore(period.endDate);
                      });
                    },
                  ),
                ),
              );

              if (event != null) {
                setState(() {
                  settings.setCalendarEvents([
                    ...settings.getCalendarEvents(),
                    event,
                  ]);
                });
              }
              SchedulerBinding.instance!.addPostFrameCallback((_) {
                _rebuildEvents(
                  context,
                  topics,
                  assignments,
                  periods,
                  _selectedDay,
                );
              });
            },
            child: Icon(Icons.add),
          ),
        );
      }),
    );
  }

  List<Widget> _getEvents(
      List<Topic> topics,
      List<Assignment> assignments,
      List<Period> periods,
      List<CustomCalendarEvent> calendarEvents,
      DateTime date) {
    final events = <Widget>[];

    final todaysAssignments =
        assignments.where((a) => a.date.isSameDay(date)).toList();
    final todaysTopics = topics.where((t) => t.date.isSameDay(date)).toList();
    final todaysCalendarEvents = calendarEvents.where((e) {
      return e.date.isSameDay(date);
    }).toList();

    todaysAssignments.sort((a1, a2) => a1.lessonHour.compareTo(a2.lessonHour));
    todaysTopics.sort((t1, t2) => t1.lessonHour.compareTo(t2.lessonHour));

    if (todaysCalendarEvents.isNotEmpty) {
      events.add(
        Text(
          context.locale.calendar.customEvents,
          style: TextStyle(
            fontFamily: Theme.of(context).textTheme.headline6!.fontFamily,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ).padding(horizontal: 16),
      );
      events.addAll(
        todaysCalendarEvents.map(
          (e) => CustomEventWidget(
            data: e,
            onLongPress: () {
              final settings = Provider.of<Settings>(context, listen: false);
              setState(() {
                _events = _getEvents(
                  topics,
                  assignments,
                  periods,
                  settings.getCalendarEvents(),
                  _selectedDay,
                );
                _selectedEvent = e;
                _editing = true;
              });
              SchedulerBinding.instance!.addPostFrameCallback((_) {
                _rebuildEvents(
                  context,
                  topics,
                  assignments,
                  periods,
                  _selectedDay,
                );
              });
            },
            isSelected: _selectedEvent == e,
          ),
        ),
      );
    }

    if (todaysAssignments.isNotEmpty) {
      events.add(
        Text(
          context.locale.calendar.homework,
          style: TextStyle(
            fontFamily: Theme.of(context).textTheme.headline6!.fontFamily,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ).padding(horizontal: 16),
      );
      events.addAll(
        todaysAssignments.map((a) => AssignmentEventWidget(data: a)),
      );
    }

    if (todaysTopics.isNotEmpty) {
      events.add(
        Text(
          context.locale.calendar.topics,
          style: TextStyle(
            fontFamily: Theme.of(context).textTheme.headline6!.fontFamily,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ).padding(horizontal: 16, top: events.isNotEmpty ? 16 : 0),
      );
      events.addAll(
        todaysTopics.map((t) => TopicEventWidget(data: t)),
      );
    }

    if (events.isEmpty) {
      events.add(
        EmptyUI(
          text: context.locale.calendar.noEvents,
          icon: Icons.event_note,
        ),
      );
    }

    return [
      SizedBox(height: 16),
      ...events,
      SizedBox(height: 8),
    ];
  }

  void _rebuildEvents(BuildContext context, List<Topic> topics,
      List<Assignment> assignments, List<Period> periods, DateTime selected) {
    final settings = Provider.of<Settings>(context, listen: false);
    setState(() {
      _events = _getEvents(
        topics,
        assignments,
        periods,
        settings.getCalendarEvents(),
        selected,
      );
    });
  }
}
