import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wyd_front/model/events/event.dart';
import 'package:wyd_front/state/media/media_flag_cache.dart';
import 'package:wyd_front/state/profile/detailed_profiles_cache.dart';
import 'package:wyd_front/state/profileEvent/detailed_profile_events_cache.dart';
import 'package:wyd_front/view/events/rounded_event_tile.dart';

class EventTile<T> extends StatelessWidget {
  const EventTile({
    super.key,
    required this.confirmedView,
    required this.date,
    required this.events,
    required this.boundary,
    required this.startDuration,
    required this.endDuration,
  });

  final bool confirmedView;
  final DateTime date;
  final List<Event> events;
  final Rect boundary;
  final DateTime startDuration;
  final DateTime endDuration;

  List<Color> _getProfileColors(BuildContext context, Event event) {
    var relatedProfiles =
        Provider.of<DetailedProfileEventsCache>(context, listen: false).relatedProfiles(event.id, confirmedView);

    final provider = Provider.of<DetailedProfileCache>(context, listen: false);

    return relatedProfiles.map((profileId) {
      final profile = provider.get(profileId);
      return profile?.color ?? Colors.purple;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) return const SizedBox.shrink();
    final mediaCache = context.read<MediaFlagCache>();

    final event = events[0];

    return Stack(
      children: [
        RoundedEventTile(
          borderRadius: BorderRadius.circular(12.0),
          title: "${event.getConfirmTitle()}${event.title}",
          totalEvents: events.length,
          padding: const EdgeInsets.fromLTRB(2.0, 0.0, 3.0, 3.0),
          margin: const EdgeInsets.all(1.5),
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          sideBarColors: _getProfileColors(context, event),
          sideBarWidth: 4,
          titleStyle: TextStyle(
            fontSize: 13,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
          descriptionStyle: event.descriptionStyle,
        ),
        if (mediaCache.hasCachedMedia(event.id))
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
