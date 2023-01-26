import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:provider/provider.dart';
import 'package:reaxios/format.dart';
import 'package:reaxios/timetable/components/essential/ColorField.dart';
import 'package:reaxios/timetable/components/essential/GradientCircleAvatar.dart';
import 'package:reaxios/timetable/components/essential/TimeField.dart';
import 'package:reaxios/timetable/extensions.dart';
import 'package:reaxios/timetable/structures/DayTime.dart';
import 'package:reaxios/timetable/structures/Settings.dart';
import 'package:reaxios/timetable/structures/Store.dart';
import 'package:reaxios/timetable/structures/Event.dart';
import 'package:reaxios/timetable/structures/Weekday.dart';
import 'package:reaxios/timetable/utils.dart';
import 'package:reaxios/utils.dart';

class EventEditor extends StatefulWidget {
  EventEditor(
      {Key? key, this.base, required this.title, required this.onSubmit})
      : super(key: key);

  final Event? base;
  final String title;
  final void Function(Event) onSubmit;

  @override
  _EventEditorState createState() => _EventEditorState();
}

class _EventEditorState extends State<EventEditor> {
  TextEditingController name = TextEditingController();
  TextEditingController abbreviation = TextEditingController();
  TextEditingController notes = TextEditingController();
  GlobalKey<FormState> formKey = GlobalKey<FormState>(debugLabel: "Form Key");
  DayTime start = DayTime.now();
  late DayTime end = DayTime.now().add(settings.getLessonDuration());
  String generatedAbbreviation = "XXX";
  Weekday weekday = Weekday.days[1]![0];
  int week = 1;
  Color color = Colors.red[400]!;

  Settings get settings => Provider.of<Settings>(context, listen: false);

  FocusNode focus = FocusNode();

  @override
  void initState() {
    super.initState();

    if (widget.base != null) {
      final b = widget.base!;

      name.text = b.name;
      abbreviation.text = b.abbr;
      notes.text = b.notes;
      start = b.start;
      end = b.end;
      weekday = b.weekday;
      color = b.color;
    }
  }

  bool _init = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_init) {
      _init = true;

      Store store = context.watch<Store>();

      if (widget.base == null) {
        if (store.startingTime != null) {
          start = store.startingTime!;
          end = store.startingTime!.add(settings.getLessonDuration());
        }

        if (store.lastWeekday != null) {
          weekday = store.lastWeekday!;
        }
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    focus.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
          child: Form(
            key: formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Name
                Padding(
                  padding: EdgeInsets.only(
                    bottom: 6.0,
                    top: 8.0,
                  ),
                  child: Text(
                    context.locale.timetable.editName,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                TypeAheadFormField<Event>(
                  textFieldConfiguration: TextFieldConfiguration(
                    controller: name,
                    decoration: InputDecoration(
                      hintText: context.locale.timetable.editNameHint,
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (val) {
                      setState(() {
                        generatedAbbreviation = generateAbbreviation(
                          3,
                          val,
                          ignoreList: settings.getIgnoreList(),
                        );
                      });
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return context.locale.timetable.editNameError;
                    }

                    return null;
                  },
                  suggestionsCallback: (pattern) async {
                    return settings
                        .getEvents()
                        .unique((s) => s.name + s.abbr)
                        .where((event) => event.name
                            .toLowerCase()
                            .contains(pattern.toLowerCase()))
                        .toSet();
                  },
                  itemBuilder: (BuildContext context, Event? itemData) {
                    if (itemData == null) return Container();
                    return ListTile(
                      title: Text(itemData.name),
                      subtitle: Text(itemData.abbr),
                      leading: GradientCircleAvatar(
                        color: itemData.color,
                        radius: 17.5,
                      ),
                    );
                  },
                  onSuggestionSelected: (Event suggestion) {
                    setState(() {
                      name.text = suggestion.name;
                      abbreviation.text = suggestion.abbr;
                      notes.text = suggestion.notes;
                      color = suggestion.color;
                    });
                  },
                ),
                // Abbreviation
                Padding(
                  padding: EdgeInsets.only(
                    bottom: 6.0,
                    top: 16.0,
                  ),
                  child: Text(
                    context.locale.timetable.editAbbreviation,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                TextFormField(
                  controller: abbreviation,
                  decoration: InputDecoration(
                    hintText: generatedAbbreviation,
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    final newValue = value
                        .toUpperCase()
                        .replaceAll(RegExp(r"[^A-Z0-9]"), "");
                    abbreviation.value = TextEditingValue(
                      text: newValue,
                      selection: TextSelection.fromPosition(
                        TextPosition(offset: newValue.length),
                      ),
                    );
                  },
                  validator: (value) {
                    if (value == null ||
                        (value.isNotEmpty && value.length != 3)) {
                      // return "Enter a valid 3-character abbreviation, or leave "
                      //     "empty to auto-generate it.";
                      return context.locale.timetable.editAbbreviationError;
                    }

                    return null;
                  },
                ),
                //
                Padding(
                  padding: EdgeInsets.only(
                    bottom: 12.0,
                    top: 16.0,
                  ),
                  child: Text(
                    context.locale.timetable.editTime,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TimeField(
                        time: start,
                        onSelect: (time) {
                          FocusScope.of(context).requestFocus(focus);
                          setState(() {
                            start = time;
                          });
                        },
                        validator: (dt) {
                          if (end.inMinutes < dt.inMinutes)
                            // return "Select a time sooner than the ending time.";
                            return context.locale.timetable.editStartError;
                        },
                        decoration: InputDecoration(
                          labelText: context.locale.timetable.editStartLabel,
                          errorMaxLines: 5,
                        ),
                      ),
                    ),
                    Icon(Icons.arrow_right),
                    Expanded(
                      child: TimeField(
                        time: end,
                        onSelect: (time) {
                          FocusScope.of(context).requestFocus(focus);
                          setState(() {
                            end = time;
                          });
                        },
                        validator: (dt) {
                          if (dt.inMinutes < start.inMinutes)
                            // return "Select a time later than the starting time.";
                            return context.locale.timetable.editEndError;
                        },
                        decoration: InputDecoration(
                          labelText: context.locale.timetable.editEndLabel,
                          errorMaxLines: 5,
                        ),
                      ),
                    ),
                  ],
                ),
                // Week
                Padding(
                  padding: EdgeInsets.only(
                    bottom: 6.0,
                    top: 16.0,
                  ),
                  child: Text(
                    context.locale.timetable.editWeek,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                DropdownButtonFormField<int>(
                  items: 1
                      .to(settings.getWeeks())
                      .map(
                        (e) => DropdownMenuItem<int>(
                          value: e,
                          // child: Text("Week $e"),
                          child: Text(
                            context.locale.timetable.editWeekLabel.format([e]),
                          ),
                        ),
                      )
                      .toList(),
                  value: week,
                  onChanged: (int? value) {
                    if (value == null) return;
                    setState(() {
                      week = value;
                      weekday = weekday.copyWith(
                        week: value,
                      );
                    });
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                ),
                // Weekday
                Padding(
                  padding: EdgeInsets.only(
                    bottom: 6.0,
                    top: 16.0,
                  ),
                  child: Text(
                    context.locale.timetable.editWeekday,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                DropdownButtonFormField<Weekday>(
                  items: Weekday.days[1]!
                      .map((e) => DropdownMenuItem(
                            child: Text(
                              e.toLongString(
                                  context.currentLocale.languageCode),
                            ),
                            value: e,
                          ))
                      .toList(),
                  value: weekday,
                  onChanged: (Weekday? value) {
                    if (value == null) return;
                    setState(() {
                      weekday = value.copyWith(
                        week: week,
                      );
                    });
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                ),
                //
                Padding(
                  padding: EdgeInsets.only(
                    bottom: 6.0,
                    top: 16.0,
                  ),
                  child: Text(
                    context.locale.timetable.editColor,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: ColorField(
                    color,
                    onChange: (c) => setState(() {
                      color = c;
                    }),
                  ),
                ),
                //
                Padding(
                  padding: EdgeInsets.only(
                    bottom: 6.0,
                    top: 16.0,
                  ),
                  child: Text(
                    context.locale.timetable.editDescription,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                TextFormField(
                  controller: notes,
                  minLines: 3,
                  maxLines: null,
                  decoration: InputDecoration(
                    // hintText: "Additional notes go here...",
                    hintText: context.locale.timetable.editDescriptionHint,
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        onPressed: processForm,
        child: Icon(Icons.done),
      ),
    );
  }

  processForm() {
    if (!formKey.currentState!.validate()) return;
    Store store = Provider.of<Store>(context, listen: false);

    store.startingTime = end;
    store.lastWeekday = weekday;

    if (end.hour == 23) {
      store.startingTime = end.add(Duration(hours: 1));
      store.lastWeekday = weekday.next;
    }

    widget.onSubmit(Event(
      name: name.text,
      notes: notes.text,
      start: start,
      end: end,
      color: color,
      weekday: weekday,
      abbr: abbreviation.text,
    ));
    Navigator.pop(context);
  }
}
