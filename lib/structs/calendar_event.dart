import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';

import '../api/entities/Assignment/Assignment.dart';
import '../api/entities/Topic/Topic.dart';
import '../components/ListItems/AssignmentListItem.dart';
import '../components/ListItems/CustomCalendarEventListItem.dart';
import '../components/ListItems/TopicListItem.dart';
import '../components/LowLevel/GradientCircleAvatar.dart';
import '../components/Utilities/CardListItem.dart';

enum EventType {
  assignment,
  topic,
  custom,
}

abstract class GenericEventWidget<T> extends StatelessWidget {
  final T data;
  final EventType type;

  const GenericEventWidget(this.type, {Key? key, required this.data})
      : super(key: key);
}

class CustomCalendarEvent {
  final String title;
  final String description;
  final DateTime date;
  final Color color;

  const CustomCalendarEvent({
    required this.title,
    required this.description,
    required this.date,
    required this.color,
  });

  factory CustomCalendarEvent.fromJson(Map<String, dynamic> json) {
    return CustomCalendarEvent(
      title: json['title'],
      description: json['description'],
      date: DateTime.parse(json['date']),
      color: Color(json['color']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'color': color.value,
    };
  }

  @override
  String toString() {
    return 'CustomCalendarEvent{title: $title, description: $description, date: $date, color: $color}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomCalendarEvent &&
          title == other.title &&
          description == other.description &&
          date == other.date &&
          color == other.color;

  @override
  int get hashCode =>
      title.hashCode ^ description.hashCode ^ date.hashCode ^ color.hashCode;
}

class AssignmentEventWidget extends GenericEventWidget<Assignment> {
  const AssignmentEventWidget({Key? key, required Assignment data})
      : super(EventType.assignment, key: key, data: data);

  @override
  Widget build(BuildContext context) => AssignmentListItem(assignment: data);
}

class TopicEventWidget extends GenericEventWidget<Topic> {
  const TopicEventWidget({Key? key, required Topic data})
      : super(EventType.topic, key: key, data: data);

  @override
  Widget build(BuildContext context) => TopicListItem(topic: data);
}

class CustomEventWidget extends GenericEventWidget<CustomCalendarEvent> {
  const CustomEventWidget({
    Key? key,
    required CustomCalendarEvent data,
    this.onLongPress,
    this.isSelected = false,
  }) : super(EventType.custom, key: key, data: data);

  final void Function()? onLongPress;
  final bool isSelected;

  @override
  Widget build(BuildContext context) => CustomCalendarEventListItem(
        event: data,
        onLongPress: onLongPress,
        isSelected: isSelected,
        onClick: () {},
      );
}
