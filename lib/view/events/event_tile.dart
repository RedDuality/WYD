import 'package:flutter/material.dart';
import 'package:wyd_front/model/event.dart';
import 'package:wyd_front/state/profiles_provider.dart';
import 'package:wyd_front/state/user_provider.dart';
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

  List<Color> getProfileColors(Event event) {
    var profileHashes = event.sharedWith
        .map((e) => e.profileHash)
        .toSet();
    List<String> ownedProfiles = profileHashes
        .intersection(UserProvider().getSecondaryProfilesHashes()).toList();
    String currentProfileHash = UserProvider().getCurrentProfileHash();
    if(profileHashes.intersection({currentProfileHash}).isNotEmpty) {
      ownedProfiles.insertAll(0, [currentProfileHash, currentProfileHash]);
    }

    final provider = ProfilesProvider();

    return ownedProfiles.map((hash) {
      final profile = provider.get(hash);
      return profile?.color ?? Colors.purple;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (events.isNotEmpty) {
      final event = events[0];
      return Stack(
        children: [
          // Main Event Tile
          RoundedEventTile(
            borderRadius: BorderRadius.circular(12.0),
            title: "${event.getConfirmTitle()}${event.title}",
            totalEvents: events.length,
            description: event.description,
            padding: const EdgeInsets.fromLTRB(2.0, 0.0, 3.0, 3.0),
            margin: const EdgeInsets.all(1.5),
            backgroundColor: event.color,
            sideBarColors: getProfileColors(event),
            sideBarWidth: 4,
            titleStyle: event.titleStyle,
            descriptionStyle: event.descriptionStyle,
          ),
          // Notification dot if there are new images
          if (event.cachedNewImages.isNotEmpty)
            Positioned(
              top: 4.0,
              right: 3.0,
              child: Container(
                width: 12.0,
                height: 12.0,
                decoration: BoxDecoration(
                  color: Colors.orange,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}
