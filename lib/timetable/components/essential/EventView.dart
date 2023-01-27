import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reaxios/format.dart';
import 'package:reaxios/timetable/extensions.dart';
import 'package:reaxios/timetable/structures/Event.dart';
import 'package:reaxios/timetable/structures/Settings.dart';
import 'package:reaxios/timetable/utils.dart';
import 'package:reaxios/utils.dart';

import 'MaybeOverflowText.dart';

class EventView extends StatefulWidget {
  EventView(
    this.event, {
    Key? key,
    this.expandable = true,
    this.actions = const {},
    this.maxWidth = double.infinity,
    this.maxHeight = double.infinity,
    this.compact = false,
    this.inverted = false,
    this.onLongPress,
  }) : super(key: key);

  final Event event;
  final bool expandable;
  final bool compact;
  final bool inverted;
  final double maxWidth, maxHeight;
  final Map<String, Function(Event)> actions;
  final Function()? onLongPress;

  @override
  _EventViewState createState() => _EventViewState();
}

class _EventViewState extends State<EventView> {
  bool expanded = false;
  // double anim = 0;
  double radius = 0;

  double get padding => widget.compact ? 4 : 16;

  @override
  Widget build(BuildContext context) {
    return getBase(context);
  }

  Widget getBase(BuildContext context) {
    final settings = context.watch<Settings>();
    final event = widget.event;
    Color bg = event.color;
    Color fg = getContrastColor(event.color);

    if (widget.inverted) {
      Color temp = bg;
      bg = fg;
      fg = temp;
    }

    final baseStyle = TextStyle(color: fg);

    final bigText = Theme.of(context).textTheme.headline6!;

    String weekText = "";
    if (settings.getWeeks() > 1) {
      // weekText = " - week ${event.weekday.week}";
      weekText = context.loc.translate("timetable.eventViewWeek").format([
        event.weekday.week,
      ]);
    }

    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      padding: EdgeInsets.symmetric(vertical: expanded ? 16 : 0),
      curve: Curves.easeInOut,
      constraints: BoxConstraints(
        maxHeight: widget.maxHeight,
        maxWidth: widget.maxWidth,
      ),
      child: Material(
        elevation: expanded ? 8 : 0,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: bg.toSlightGradient(context),
            ),
            borderRadius: BorderRadius.circular(radius),
          ),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              splashColor: fg.withOpacity(0.172),
              borderRadius: BorderRadius.circular(radius),
              onTap: widget.expandable
                  ? () {
                      setState(() {
                        expanded = !expanded;
                        // radius = expanded ? 24 : 0;
                        // padding = expanded ? 24 : 16;
                      });
                    }
                  : null,
              onLongPress: widget.onLongPress,
              child: Container(
                padding: EdgeInsets.all(padding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    MaybeOverflowText(
                      event.name,
                      event.abbr,
                      style: bigText.copyWith(
                          color: fg,
                          fontSize: widget.compact
                              ? bigText.fontSize! * 0.75
                              : bigText.fontSize),
                    ),
                    Text(
                      context.loc.translate("timetable.eventViewTime").format([
                        event.start.format(context),
                        event.end.format(context),
                        weekText,
                      ]),
                      style: baseStyle.copyWith(
                          fontSize: widget.compact
                              ? (baseStyle.fontSize ?? 14) * 0.75
                              : baseStyle.fontSize),
                      maxLines: widget.compact ? 1 : 2,
                    ),
                    AnimatedCrossFade(
                      firstChild: Container(),
                      secondChild: _themed(getActions()),
                      crossFadeState: expanded
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      duration: Duration(milliseconds: 300),
                      sizeCurve: Curves.easeInOut,
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _themed(Widget child) {
    final event = widget.event;
    final fg = getContrastColor(event.color);
    final brightness =
        fg.computeLuminance() >= 0.5 ? Brightness.dark : Brightness.light;
    return Theme(
      data: ThemeData(
        // colorScheme: ColorScheme.dark(
        //   primary: fg,
        // ).copyWith(
        // ),
        primaryColor: fg,
        colorScheme: ColorScheme(
          primary: fg,
          primaryVariant: fg,
          secondary: fg,
          secondaryVariant: fg,
          surface: fg,
          background: fg,
          error: fg,
          onPrimary: fg,
          onSecondary: fg,
          onSurface: fg,
          onBackground: fg,
          onError: fg,
          brightness: brightness,
        ),
        splashColor: fg,
        brightness: brightness,
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: ButtonStyle(
            foregroundColor: MaterialStateProperty.all(fg),
          ),
        ),
      ),
      child: child,
    );
  }

  Widget getActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(),
        ...widget.actions.entries.map((entry) {
          return OutlinedButton(
            child: Text(context.loc.translate("timetable.actions${entry.key}")),
            onPressed: () {
              entry.value(widget.event);
            },
          );
        })
      ],
    );
  }
}
