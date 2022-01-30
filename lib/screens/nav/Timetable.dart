import 'package:flutter/material.dart';
import 'package:reaxios/components/LowLevel/RestartWidget.dart';
import 'package:reaxios/timetable/components/views/EventController.dart';

class TimetablePane extends StatelessWidget {
  final void Function() openMainDrawer;

  const TimetablePane({
    Key? key,
    required this.openMainDrawer,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RestartWidget(
      child: EventController(
        openMainDrawer: openMainDrawer,
      ),
    );
  }
}
