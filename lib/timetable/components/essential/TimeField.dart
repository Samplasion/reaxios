import 'package:flutter/material.dart';
import 'package:reaxios/timetable/structures/DayTime.dart';

class TimeField extends StatefulWidget {
  TimeField({
    Key? key,
    this.decoration,
    required this.time,
    required this.onSelect,
    this.validator,
  }) : super(key: key);

  final InputDecoration? decoration;
  final DayTime time;
  final void Function(DayTime) onSelect;
  final String? Function(DayTime)? validator;

  @override
  _TimeFieldState createState() => _TimeFieldState();
}

class _TimeFieldState extends State<TimeField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: (widget.decoration ?? InputDecoration()).copyWith(
        border: OutlineInputBorder(),
      ),
      controller: TextEditingController(text: widget.time.format(context)),
      onTap: _openDialog,
      validator: widget.validator != null ? _validator : null,
    );
  }

  _openDialog() async {
    TimeOfDay? time =
        await showTimePicker(context: context, initialTime: widget.time);
    if (time != null) widget.onSelect(DayTime.fromTimeOfDay(time));
  }

  String? _validator(_) {
    return widget.validator!(widget.time);
  }
}
