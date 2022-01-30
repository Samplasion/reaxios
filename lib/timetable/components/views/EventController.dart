import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reaxios/components/LowLevel/RestartWidget.dart';
import 'package:reaxios/timetable/components/views/DayView.dart';
import 'package:reaxios/timetable/components/views/EventMassEditor.dart';
import 'package:reaxios/timetable/components/views/WeekView.dart';
import 'package:reaxios/timetable/structures/Settings.dart';
import 'package:reaxios/timetable/structures/Event.dart';
import 'package:reaxios/utils.dart';

import 'EventEditor.dart';

enum View { dayView, weekView }

class EventController extends StatefulWidget {
  final void Function() openMainDrawer;

  EventController({
    Key? key,
    required this.openMainDrawer,
  }) : super(key: key);

  @override
  _EventControllerState createState() => _EventControllerState();

  static _EventControllerState? of(BuildContext context) =>
      context.findAncestorStateOfType<_EventControllerState>();
}

class _Page {
  final Widget view;
  final Widget icon;
  final Widget title;

  _Page(
    this.view, {
    required this.icon,
    required this.title,
  });
}

class _EventControllerState extends State<EventController> {
  List<Event> _events = [];

  Settings getSettings(BuildContext context) =>
      Provider.of<Settings>(context, listen: false);

  int _currentIndex = 0;
  late PageController _pageController;

  goToTab(int tab) {
    setState(() => _currentIndex = tab);
    _pageController.animateToPage(
      tab,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeIn,
    );
  }

  List<_Page> _getPages(BuildContext context) => [
        _Page(
          AnimatedBuilder(
            animation: getSettings(context),
            builder: (context, child) => DayView(
              _events,
              fab: _getFab(),
              actions: _actions,
              massEdit: _massEdit,
              openMainDrawer: widget.openMainDrawer,
            ),
          ),
          title: Text(context.locale.timetable.dayView),
          icon: Icon(Icons.calendar_view_day),
        ),
        _Page(
          AnimatedBuilder(
            animation: getSettings(context),
            builder: (context, child) => WeekView(
              _events,
              fab: _getFab(),
              actions: _actions,
              openMainDrawer: widget.openMainDrawer,
            ),
          ),
          title: Text(context.locale.timetable.weekView),
          icon: Icon(Icons.calendar_view_week),
        ),
      ];

  @override
  void initState() {
    super.initState();
    _events = getSettings(context).getEvents();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  _addEvent(Event event) {
    setState(() {
      _events.add(event);
    });
    getSettings(context).setEvents(_events);
  }

  _removeEvent(Event event) {
    setState(() {
      _events = _events.where((s) => !(s == event)).toList();
    });
    getSettings(context).setEvents(_events);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Builder(
        builder: (context) => AnimatedContainer(
          duration: Duration(milliseconds: 5500),
          child: PageView(
            physics: NeverScrollableScrollPhysics(),
            controller: _pageController,
            children: _getPages(context).map((e) => e.view).toList(),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavyBar(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        selectedIndex: _currentIndex,
        onItemSelected: (index) {
          goToTab(index);
        },
        items: _getPages(context)
            .map((e) => BottomNavyBarItem(
                  icon: e.icon,
                  title: e.title,
                  activeColor: Theme.of(context).colorScheme.secondary,
                ))
            .toList(),
      ),
    );
  }

  _massEdit() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EventMassEditor(
          events: _events,
          onSet: (name, transformation) {
            var removed = _events.where((element) => element.name == name);
            removed = removed.map((s) => transformation.apply(s));
            setState(() {
              _events = [
                ..._events.where((element) => element.name != name),
                ...removed
              ];
            });
            getSettings(context).setEvents(_events);
          },
        ),
      ),
    );
  }

  Map<String, Function(Event)> get _actions => {
        "Clone": (event) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EventEditor(
                title: context.locale.timetable.actionsClone,
                base: event,
                onSubmit: _addEvent,
              ),
            ),
          );
        },
        "Edit": (event) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EventEditor(
                title: context.locale.timetable.actionsEdit,
                base: event,
                onSubmit: (s) {
                  _removeEvent(event);
                  _addEvent(s);
                },
              ),
            ),
          );
        },
        "Delete": (event) {
          _removeEvent(event);
        },
      };

  FloatingActionButton _getFab() {
    return FloatingActionButton(
      tooltip: context.locale.timetable.actionsAdd,
      child: Icon(Icons.add),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => Builder(
              builder: (context) => EventEditor(
                title: context.locale.timetable.addEvent,
                onSubmit: _addEvent,
              ),
            ),
          ),
        );
      },
    );
  }
}
