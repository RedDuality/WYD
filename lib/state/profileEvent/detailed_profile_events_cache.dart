import 'dart:async';
import 'package:flutter/material.dart';
import 'package:wyd_front/model/enum/event_role.dart';
import 'package:wyd_front/model/profiles/profile_event.dart';
import 'package:wyd_front/view/events/event_view_orchestrator.dart';
import 'package:wyd_front/state/profileEvent/detailed_profile_events_storage.dart';
import 'package:wyd_front/state/user/user_cache.dart';

class DetailedProfileEventsCache extends ChangeNotifier {
  EventViewOrchestrator? _provider;

  final DetailedProfileEventsStorage _storage = DetailedProfileEventsStorage();

  late final StreamSubscription<(String eventId, Set<ProfileEvent> pes)> _addChannel;
  late final StreamSubscription<ProfileEvent> _updateChannel;
  late final StreamSubscription<(String eventId, String profileId)> _deleteChannel;
  late final StreamSubscription<String> _deleteAllChannel;
  late final StreamSubscription<void> _clearAllChannel;

  final Map<String, Set<ProfileEvent>> _profileEvents = {};

  DetailedProfileEventsCache() {
    _updateChannel = _storage.updatesChannel.listen((pe) {
      // only for updates, the insertions are handled by currentEventsProvider
      _update(pe);
    });
    _deleteChannel = _storage.deleteChannel.listen((data) {
      _removeSingle(data.$1, data.$2);
    });
    _deleteAllChannel = _storage.deleteAllChannel.listen((eventId) {
      remove(eventId);
    });

    _clearAllChannel = _storage.clearChannel.listen((_) {
      clearAll();
    });
  }

  void setViewProvider(EventViewOrchestrator? provider) {
    _provider = provider;
  }

  Set<ProfileEvent> get(String eventId) {
    return _profileEvents[eventId]!;
  }

  // e.g. someone confirmed
  void _update(ProfileEvent pe) {
    final set = _profileEvents[pe.eventId];

    if (set != null || set!.isNotEmpty) {
      set.remove(pe);
      set.add(pe);

      notifyListeners();
    }
  }

  Future<void> synchWithCachedEvents() async {
    if (_provider == null) return;
    final currentEventsIds = _provider!.currentEventsIds();
    _profileEvents.removeWhere((id, _) => !currentEventsIds.contains(id));

    final missingIds = currentEventsIds.difference(_profileEvents.keys.toSet());

    if (missingIds.isNotEmpty) {
      final fetched = await _storage.getAllForEvents(missingIds.toList());

      fetched.forEach((eventId, setOfEvents) {
        _profileEvents[eventId] = setOfEvents;
      });
    }
  }

  Future<void> loadCorrespondingProfileEvents(Set<String> eventIds) async {
    final fetched = await _storage.getAllForEvents(eventIds.toList());
    fetched.forEach((eventId, events) {
      if (_profileEvents.containsKey(eventId)) {
        _profileEvents[eventId]!.addAll(events);
      } else {
        _profileEvents[eventId] = events;
      }
    });
  }

  Future<void> loadProfileEvents(String newEventId) async {
    final fetched = await _storage.getAll(newEventId);
    _profileEvents[newEventId] = fetched;
  }

  void remove(String eventId) {
    if (_profileEvents.containsKey(eventId)) {
      _profileEvents.remove(eventId);
      notifyListeners();
    }
  }

  void _removeSingle(String eventId, String profileId) {
    _profileEvents[eventId]?.removeWhere((pe) => pe.profileId == profileId);
  }

  void clearAll() {
    _profileEvents.clear();
  }

  @override
  void dispose() {
    _addChannel.cancel();
    _updateChannel.cancel();
    _deleteAllChannel.cancel();
    _deleteChannel.cancel();
    _clearAllChannel.cancel();
    super.dispose();
  }

  Set<String> eventsWithProfilesConfirmed(Set<String> eventIds,
      {Set<String> profileIds = const {}, bool confirmed = true}) {
    final Set<String> matchingEvents = {};
    for (final eventId in eventIds) {
      if (atLeastOneConfirmed(eventId, profileIds: profileIds, confirmed: confirmed)) {
        matchingEvents.add(eventId);
      }
    }
    return matchingEvents;
  }

  bool atLeastOneConfirmed(String eventId, {Set<String> profileIds = const {}, bool confirmed = true}) {
    if (profileIds.isEmpty) profileIds = UserCache().getProfileIds();
    final profiles = _profileEvents[eventId] ?? {};
    return profiles.any(
      (pe) => profileIds.contains(pe.profileId) && pe.confirmed == confirmed,
    );
  }

  Set<String> relatedProfiles(String eventId, bool confirmed) {
    var myProfileIds = UserCache().getProfileIds();
    final eventProfiles = _profileEvents[eventId] ?? {};
    return eventProfiles
        .where((pe) => pe.confirmed == confirmed && myProfileIds.contains(pe.profileId))
        .map((pe) => pe.profileId)
        .toSet();
  }

  bool currentConfirmed(String eventId) {
    final currentProfileId = UserCache().getCurrentProfileId();
    final pe = _profileEvents[eventId]?.where((pe) => pe.profileId == currentProfileId).firstOrNull!;
    return pe != null ? pe.confirmed : false;
  }

  bool isOwner(String eventId) {
    final currentProfileId = UserCache().getCurrentProfileId();
    final pe = _profileEvents[eventId]?.where((pe) => pe.profileId == currentProfileId).firstOrNull!;
    return pe != null ? pe.role == EventRole.owner : false;
  }
}
