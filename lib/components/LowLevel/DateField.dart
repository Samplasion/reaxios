import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:reaxios/timetable/structures/DayTime.dart';
import 'package:reaxios/utils.dart';

class DateField extends StatefulWidget {
  DateField({
    Key? key,
    this.decoration,
    required this.date,
    required this.onSelect,
    this.validator,
    this.firstDate,
    this.lastDate,
    this.selectableDayPredicate,
  }) : super(key: key);

  final InputDecoration? decoration;
  final DateTime date;
  final void Function(DateTime) onSelect;
  final String? Function(DateTime)? validator;
  DateTime? firstDate;
  DateTime? lastDate;
  bool Function(DateTime)? selectableDayPredicate;

  @override
  _DateFieldState createState() => _DateFieldState();
}

class _DateFieldState extends State<DateField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: (widget.decoration ?? InputDecoration()).copyWith(
        border: OutlineInputBorder(),
      ),
      controller: TextEditingController(
        text: DateFormat.yMEd(context.currentLocale.languageCode)
            .format(widget.date),
      ),
      onTap: _openDialog,
      validator: widget.validator != null ? _validator : null,
    );
  }

  _openDialog() async {
    DateTime? time = await showDatePicker(
      context: context,
      initialDate: widget.date,
      firstDate: widget.firstDate ?? DateTime.now(),
      lastDate: widget.lastDate ?? DateTime(DateTime.now().year + 1),
    );
    if (time != null) widget.onSelect(time);
  }

  String? _validator(_) {
    return widget.validator!(widget.date);
  }
}
