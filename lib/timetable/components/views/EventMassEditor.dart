import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reaxios/timetable/components/essential/ColorField.dart';
import 'package:reaxios/timetable/components/essential/GradientAppBar.dart';
import 'package:reaxios/timetable/structures/Settings.dart';
import 'package:reaxios/timetable/structures/Event.dart';
import 'package:reaxios/timetable/utils.dart';

class EventMassEditor extends StatefulWidget {
  EventMassEditor({
    Key? key,
    required this.events,
    required this.onSet,
  }) : super(key: key);

  final List<Event> events;
  final void Function(String, EventTransformation) onSet;

  @override
  _EventMassEditorState createState() => _EventMassEditorState();
}

class _EventMassEditorState extends State<EventMassEditor> {
  String selectedEvent = "";
  TextEditingController name = TextEditingController();
  TextEditingController abbreviation = TextEditingController();
  Color color = Colors.red[400]!;
  String generatedAbbreviation = "XXX";

  GlobalKey<FormState> formKey = GlobalKey<FormState>(debugLabel: "Form Key");

  Settings get settings => Provider.of<Settings>(context, listen: false);

  @override
  void initState() {
    super.initState();
    selectedEvent = widget.events[0].name;
    name.text = selectedEvent;
    abbreviation.text = widget.events[0].abbr;
    color = widget.events[0].color;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        title: Text("Edit multiple events"),
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
                // Event selector
                Padding(
                  padding: EdgeInsets.only(
                    bottom: 6.0,
                    top: 16.0,
                  ),
                  child: Text(
                    "Select a event",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                DropdownButtonFormField<String>(
                  items: widget.events
                      .map((s) => s.name)
                      .toSet()
                      .map((s) => DropdownMenuItem(child: Text(s), value: s))
                      .toList(),
                  value: selectedEvent,
                  onChanged: (String? value) {
                    if (value == null) return;
                    List<Event> corresponding =
                        widget.events.where((s) => s.name == value).toList();
                    setState(() {
                      selectedEvent = value;
                      name.text = value;
                      abbreviation.text = corresponding[0].abbr;
                      color = corresponding[0].color;
                    });
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                ),
                // Name
                Padding(
                  padding: EdgeInsets.only(
                    bottom: 6.0,
                    top: 8.0,
                  ),
                  child: Text(
                    "Name",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                TextFormField(
                  controller: name,
                  decoration: InputDecoration(
                    hintText: "Event name",
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
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Enter a valid name.";
                    }

                    return null;
                  },
                ),
                // Abbreviation
                Padding(
                  padding: EdgeInsets.only(
                    bottom: 6.0,
                    top: 16.0,
                  ),
                  child: Text(
                    "Abbreviation",
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
                      return "Enter a valid 3-character abbreviation, or leave "
                          "empty to auto-generate it.";
                    }

                    return null;
                  },
                ),
                //
                Padding(
                  padding: EdgeInsets.only(
                    bottom: 6.0,
                    top: 16.0,
                  ),
                  child: Text(
                    "Color",
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
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: processForm,
        child: Icon(Icons.done),
      ),
    );
  }

  processForm() {
    if (!formKey.currentState!.validate()) return;
    widget.onSet(
      selectedEvent,
      EventTransformation(
        name: name.text,
        color: color,
        abbr: abbreviation.text,
      ),
    );
    Navigator.pop(context);
  }
}