import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reaxios/timetable/components/views/DayView.dart';
import 'package:reaxios/timetable/components/views/HomeView.dart';
import 'package:reaxios/timetable/components/views/SettingsView.dart';
import 'package:reaxios/timetable/components/views/EventMassEditor.dart';
import 'package:reaxios/timetable/components/views/WeekView.dart';
import 'package:reaxios/timetable/extensions.dart';
import 'package:reaxios/timetable/structures/Settings.dart';
import 'package:reaxios/timetable/structures/Event.dart';

import 'EventEditor.dart';

enum View { dayView, weekView }

class EventController extends StatefulWidget {
  EventController({Key? key}) : super(key: key);

  @override
  _EventControllerState createState() => _EventControllerState();

  static _EventControllerState? of(BuildContext context) =>
      context.findAncestorStateOfType<_EventControllerState>();
}

class _Page {
  final Widget view;
  final Color primaryColor;
  final Color secondaryColor;
  final Widget icon;
  final Widget title;

  BottomNavyBarItem get item => BottomNavyBarItem(
        icon: icon,
        title: title,
        activeColor: primaryColor,
      );

  ThemeData getTheme(BuildContext context) => ThemeData(
        colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: primaryColor,
              onPrimary: primaryColor.contrastColor,
              secondary: secondaryColor,
              onSecondary: secondaryColor.contrastColor,
            ),
      );

  _Page(
    this.view,
    this.primaryColor,
    this.secondaryColor, {
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
          HomeView(),
          Colors.green,
          Colors.redAccent,
          icon: Icon(Icons.home),
          title: Text('Home'),
        ),
        _Page(
          Consumer<Settings>(
            builder: (context, settings, child) => DayView(
              _events,
              fab: _getFab(),
              actions: _actions,
              massEdit: _massEdit,
            ),
          ),
          Colors.red,
          Colors.blueAccent,
          title: Text('Day view'),
          icon: Icon(Icons.calendar_view_day),
        ),
        _Page(
          Consumer<Settings>(
            builder: (context, settings, child) => WeekView(
              _events,
              fab: _getFab(),
              actions: _actions,
            ),
          ),
          Colors.blue,
          Colors.orangeAccent,
          title: Text('Week view'),
          icon: Icon(Icons.calendar_view_week),
        ),
        _Page(
          SettingsView(),
          Colors.orange,
          Colors.green,
          title: Text('Settings'),
          icon: Icon(Icons.settings),
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
            children: _getPages(context)
                .map((e) => Theme(
                      data: e.getTheme(context),
                      child: e.view,
                    ))
                .toList(),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavyBar(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        selectedIndex: _currentIndex,
        onItemSelected: (index) {
          goToTab(index);
        },
        items: _getPages(context).map((e) => e.item).toList(),
      ),
    );
  }

  _massEdit() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Theme(
          data: _getPages(context)[_currentIndex].getTheme(context),
          child: EventMassEditor(
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
      ),
    );
  }

  Map<String, Function(Event)> get _actions => {
        "Clone": (event) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EventEditor(
                title: "Clone Event",
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
                title: "Edit Event",
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
      tooltip: "Add event",
      child: Icon(Icons.add),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => Builder(
              builder: (context) => Theme(
                data: _getPages(context)[_currentIndex].getTheme(context),
                child: EventEditor(
                  title: "Add Event",
                  onSubmit: _addEvent,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
