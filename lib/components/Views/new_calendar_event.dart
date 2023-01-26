import 'package:flutter/material.dart';
import 'package:reaxios/components/LowLevel/DateField.dart';
import 'package:reaxios/components/Utilities/MaxWidthContainer.dart';
import 'package:reaxios/structs/calendar_event.dart';
import 'package:reaxios/timetable/components/essential/ColorField.dart';
import 'package:reaxios/utils.dart';

class _SmallTitle extends StatelessWidget {
  final String text;
  const _SmallTitle(this.text, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: 6.0,
        top: 16.0,
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Theme.of(context).colorScheme.secondary,
          fontWeight: FontWeight.bold,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class CalendarEventEditorView extends StatefulWidget {
  const CalendarEventEditorView({
    Key? key,
    this.baseEvent,
    this.firstDate,
    this.lastDate,
    this.selectableDayPredicate,
    this.selectedDate,
  }) : super(key: key);

  final CustomCalendarEvent? baseEvent;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final bool Function(DateTime)? selectableDayPredicate;
  final DateTime? selectedDate;

  @override
  State<CalendarEventEditorView> createState() =>
      _CalendarEventEditorViewState();
}

class _CalendarEventEditorViewState extends State<CalendarEventEditorView> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _titleController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  late DateTime _selectedDate;
  Color? _selectedColor;

  @override
  void initState() {
    super.initState();

    final baseEvent = widget.baseEvent;
    if (baseEvent != null) {
      _titleController.text = baseEvent.title;
      _descriptionController.text = baseEvent.description;
      _selectedDate = baseEvent.date;
      _selectedColor = baseEvent.color;
    } else {
      _selectedDate = widget.selectedDate ?? DateTime.now();
    }
  }

  @override
  Widget build(BuildContext context) {
    _selectedColor ??= Theme.of(context).colorScheme.primary;
    return Scaffold(
      appBar: AppBar(
        title: Text(context.locale.calendar.eventEditorTitle),
      ),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: ListView(
          children: <Widget>[
            Container(),
            _SmallTitle(context.locale.calendar.eventEditorSubject),
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return context.locale.calendar.eventEditorTextError;
                }
                return null;
              },
            ),
            _SmallTitle(context.locale.calendar.eventEditorDescription),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
              ),
              minLines: 3,
              maxLines: null,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return context.locale.calendar.eventEditorTextError;
                }
                return null;
              },
            ),
            _SmallTitle(context.locale.calendar.eventEditorDate),
            DateField(
              date: _selectedDate,
              onSelect: (date) {
                setState(() {
                  _selectedDate = date;
                });
              },
              firstDate: widget.firstDate,
              lastDate: widget.lastDate,
              selectableDayPredicate: widget.selectableDayPredicate,
            ),
            _SmallTitle(context.locale.calendar.eventEditorColor),
            ColorField(_selectedColor!, onChange: (c) {
              setState(() {
                _selectedColor = c;
              });
            }),
            ElevatedButton(
              child: Text(context.materialLocale.saveButtonLabel),
              onPressed: () {
                if (_formKey.currentState != null &&
                    _formKey.currentState!.validate()) {
                  // Save the event
                  CustomCalendarEvent event = CustomCalendarEvent(
                    title: _titleController.text,
                    description: _descriptionController.text,
                    date: _selectedDate,
                    color: _selectedColor!,
                  );
                  Navigator.pop(context, event);
                }
              },
            ),
            Container(),
          ].map((e) {
            return Center(
              child: MaxWidthContainer(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: e is _SmallTitle ? 0 : 8,
                    horizontal: 16,
                  ),
                  child: e,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
