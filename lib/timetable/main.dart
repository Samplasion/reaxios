import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'components/essential/RestartWidget.dart';
import 'components/views/EventController.dart';
import 'structures/Settings.dart';
import 'structures/Store.dart';

class TimetablePane extends StatelessWidget {
  const TimetablePane({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RestartWidget(child: EventController());
  }
}