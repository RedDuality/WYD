import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:wyd_front/model/event.dart';

class EventTile<T> extends StatelessWidget {
  const EventTile({
    super.key,
    required this.date,
    required this.events,
    required this.boundary,
    required this.startDuration,
    required this.endDuration,
  });

  final DateTime date;
  final List<Event> events;
  final Rect boundary;
  final DateTime startDuration;
  final DateTime endDuration;

  @override
  Widget build(BuildContext context) {
    if (events.isNotEmpty) {
      final event = events[0];
      return RoundedEventTile(
        borderRadius: BorderRadius.circular(8.0),
        title: "${event.getConfirmTitle()}${event.title}",
        totalEvents: events.length,
        description: event.description,
        padding: const EdgeInsets.fromLTRB(4.0, 0.0, 3.0, 3.0),
        backgroundColor: event.color,
        margin: const EdgeInsets.all(1.5),
        titleStyle: event.titleStyle,
        descriptionStyle: event.descriptionStyle,
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}
