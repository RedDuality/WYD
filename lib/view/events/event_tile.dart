import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wyd_front/model/event.dart';
import 'package:wyd_front/state/profile/profiles_provider.dart';
import 'package:wyd_front/view/events/rounded_event_tile.dart';

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

  Future<List<Color>?> getProfileColors(BuildContext context, Event event) async {
    var profilesConfirmed = await event.profilesThatConfirmed();
    if (context.mounted) {
      final provider = Provider.of<ProfileProvider>(context, listen: false);

      return profilesConfirmed.map((hash) {
        final profile = provider.get(hash);
        return profile?.color ?? Colors.purple;
      }).toList();
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) return const SizedBox.shrink();

    final event = events[0];

    return Stack(
      children: [
        FutureBuilder<List<Color>?>(
          future: getProfileColors(context, event),
          builder: (context, snapshot) {
            final sideBarColors = snapshot.data ?? [event.color];
            return RoundedEventTile(
              borderRadius: BorderRadius.circular(12.0),
              title: "${event.getConfirmTitle()}${event.title}",
              totalEvents: events.length,
              padding: const EdgeInsets.fromLTRB(2.0, 0.0, 3.0, 3.0),
              margin: const EdgeInsets.all(1.5),
              backgroundColor: event.color,
              sideBarColors: sideBarColors,
              sideBarWidth: 4,
              titleStyle: event.titleStyle,
              descriptionStyle: event.descriptionStyle,
            );
          },
        ),
        if (event.hasCachedMedia)
          Positioned(
            top: 4.0,
            right: 3.0,
            child: Container(
              width: 12.0,
              height: 12.0,
              decoration: const BoxDecoration(
                color: Colors.orange,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }
}
