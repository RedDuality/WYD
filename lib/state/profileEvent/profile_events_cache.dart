import 'dart:async';
import 'package:flutter/material.dart';
import 'package:wyd_front/model/enum/event_role.dart';
import 'package:wyd_front/model/profile_event.dart';
import 'package:wyd_front/state/profileEvent/profile_events_storage.dart';
import 'package:wyd_front/state/user/user_provider.dart';

class ProfileEventsCache extends ChangeNotifier {
  final ProfileEventsStorage _storage = ProfileEventsStorage();
  late final StreamSubscription<ProfileEvent> _profileEventSubscription;

  final Map<String, Set<ProfileEvent>> _profileEvents = {};

  Set<ProfileEvent> get(String eventId) {
    return _profileEvents[eventId]!;
  }

  ProfileEventsCache() {
    _profileEventSubscription = _storage.updates.listen((pe) {
      // only for updates, the insertions are handled by currentEventsProvider
      _update(pe);
    });
  }

  void _update(ProfileEvent pe) {
    final set = _profileEvents[pe.eventId];

    if (set != null || set!.isNotEmpty) {
      set.remove(pe);
      set.add(pe);

      notifyListeners();
    }
  }

  Future<void> rangeChanged(Set<String> newEventIds) async {
    _profileEvents.removeWhere((id, _) => !newEventIds.contains(id));

    final missingIds = newEventIds.difference(_profileEvents.keys.toSet());

    if (missingIds.isNotEmpty) {
      final fetched = await _storage.getAllForEvents(missingIds.toList());

      fetched.forEach((eventId, setOfEvents) {
        _profileEvents[eventId] = setOfEvents;
      });
    }
  }

  Future<void> remove(String eventId) async {
    if (_profileEvents.containsKey(eventId)) {
      _profileEvents.remove(eventId);
    }
  }

  Future<void> removeSingle(String eventId, String profileId) async {
    _profileEvents[eventId]?.removeWhere((pe) => pe.profileId == profileId);
  }

  Future<void> add(String eventId) async {
    var pes = await ProfileEventsStorage().getAll(eventId);
    _profileEvents[eventId] = pes;
  }

  @override
  void dispose() {
    _profileEventSubscription.cancel();
    super.dispose();
  }

  Set<String> eventsWithProfilesConfirmed(
    Set<String> eventIds,
    Set<String> profileIds,
    bool confirmed,
  ) {
    final Set<String> matchingEvents = {};
    for (final eventId in eventIds) {
      final profiles = _profileEvents[eventId] ?? {};
      final hasMatch = profiles.any(
        (pe) => profileIds.contains(pe.profileId) && pe.confirmed == confirmed,
      );
      if (hasMatch) {
        matchingEvents.add(eventId);
      }
    }
    return matchingEvents;
  }

  int countMatchingProfiles(String eventId) {
    var myProfileIds = UserProvider().getProfileIds();
    final eventProfiles = _profileEvents[eventId] ?? {};
    return eventProfiles.where((pe) => myProfileIds.contains(pe.profileId)).length;
  }

  Set<String> profilesThatConfirmed(String eventId) {
    var myProfileIds = UserProvider().getProfileIds();
    final eventProfiles = _profileEvents[eventId] ?? {};
    return eventProfiles
        .where((pe) => pe.confirmed && myProfileIds.contains(pe.profileId))
        .map((pe) => pe.profileId)
        .toSet();
  }

  bool currentConfirmed(String eventId) {
    final currentProfileId = UserProvider().getCurrentProfileId();
    final pe = _profileEvents[eventId]?.where((pe) => pe.profileId == currentProfileId).firstOrNull!;
    return pe != null ? pe.confirmed : false;
  }

  bool isOwner(String eventId) {
    final currentProfileId = UserProvider().getCurrentProfileId();
    final pe = _profileEvents[eventId]?.where((pe) => pe.profileId == currentProfileId).firstOrNull!;
    return pe != null ? pe.role == EventRole.owner : false;
  }
}
