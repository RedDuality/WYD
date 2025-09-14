import 'package:flutter/foundation.dart';
import 'package:wyd_front/model/profile_event.dart';

// Assuming ProfileEvent and EventRole are defined elsewhere
class ProfileEventsProvider extends ChangeNotifier {
  static final ProfileEventsProvider _instance = ProfileEventsProvider._internal();

  factory ProfileEventsProvider() {
    return _instance;
  }

  ProfileEventsProvider._internal();

  final Map<String, Set<ProfileEvent>> _profileEvents = {};

  Set<ProfileEvent> get(String eventHash) => _profileEvents[eventHash]!;

  ProfileEvent getSingle(String eventHash, String profileHash) =>
      get(eventHash).firstWhere((pe) => pe.profileHash == profileHash);

  void add(String eventId, List<ProfileEvent> newProfileEvents) {
    // Get the existing Set or create a new one
    final existingEventsSet = _profileEvents[eventId] ?? <ProfileEvent>{};

    // Add all new profile events to the set.
    existingEventsSet.addAll(newProfileEvents);

    _profileEvents[eventId] = existingEventsSet;
    notifyListeners();
  }

  void setSingle(String eventHash, ProfileEvent profileHash) {
    _profileEvents[eventHash]!.add(profileHash);
  }

  void remove(String eventHash) {
    _profileEvents.remove(eventHash);
  }

  void confirm(String eventHash, String profileHash) {
    var pe = getSingle(eventHash, profileHash);
    pe.confirmed = true;
    setSingle(eventHash, pe);
  }

  void dismiss(String eventHash, String profileHash) {
    var pe = getSingle(eventHash, profileHash);
    pe.confirmed = false;
    setSingle(eventHash, pe);
  }
}
