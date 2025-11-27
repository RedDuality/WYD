import 'dart:async';
import 'package:flutter/material.dart';
import 'package:wyd_front/model/enum/event_role.dart';
import 'package:wyd_front/model/profiles/profile_event.dart';
import 'package:wyd_front/state/event_view_orchestrator.dart';
import 'package:wyd_front/state/profileEvent/profile_events_storage.dart';
import 'package:wyd_front/state/user/user_cache.dart';

class ProfileEventsCache extends ChangeNotifier {
  EventViewOrchestrator? _provider;

  final ProfileEventsStorage _storage = ProfileEventsStorage();

  late final StreamSubscription<(String, Set<ProfileEvent>)> _addChannel;
  late final StreamSubscription<ProfileEvent> _updateChannel;
  late final StreamSubscription<(String, String)> _deleteChannel;
  late final StreamSubscription<String> _deleteAllChannel;

  final Map<String, Set<ProfileEvent>> _profileEvents = {};

  ProfileEventsCache() {
    _addChannel = _storage.addChannel.listen((pe) {
      addProfileEvents(pe.$1, pe.$2);
    });
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
  }

  void setViewProvider(EventViewOrchestrator? provider) {
    _provider = provider;
  }

  Set<ProfileEvent> get(String eventId) {
    return _profileEvents[eventId]!;
  }

  Future<void> addProfileEvents(String eventId, Set<ProfileEvent> profileEvents) async {
    if (_provider != null && _provider!.currentEventsIds().contains(eventId)) {
      _profileEvents[eventId] = profileEvents;
    }
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

  Future<void> loadCorrespondingProfileEvents(Set<String> newEventIds) async {
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

  Future<void> _removeSingle(String eventId, String profileId) async {
    _profileEvents[eventId]?.removeWhere((pe) => pe.profileId == profileId);
  }

  @override
  void dispose() {
    _addChannel.cancel();
    _updateChannel.cancel();
    _deleteAllChannel.cancel();
    _deleteChannel.cancel();
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
