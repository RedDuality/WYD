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

  ProfileEvent? getSingle(String eventHash, String profileHash) =>
      get(eventHash).firstWhere((pe) => pe.profileHash == profileHash);

  void add(String eventId, Set<ProfileEvent> newProfileEvents) {
    // Get the existing Set or create a new one
    final existingEventsSet = _profileEvents[eventId] ?? <ProfileEvent>{};

    // Add all new profile events to the set.
    existingEventsSet.addAll(newProfileEvents);

    _profileEvents[eventId] = existingEventsSet;
    notifyListeners();
  }

  void remove(String eventHash) {
    _profileEvents.remove(eventHash);
  }

  void setSingle(String eventHash, ProfileEvent profileHash) {
    _profileEvents[eventHash]!.add(profileHash);
  }

  void removeSingle(String eventHash, String profileHash) {
    _profileEvents[eventHash]!.removeWhere((pe) => pe.profileHash == profileHash);
  }

  bool confirm(String eventHash, bool confirmed, String profileHash) {
    var pe = getSingle(eventHash, profileHash);
    if (pe != null) {
      if (pe.confirmed != confirmed) {
        pe.confirmed = confirmed;
        setSingle(eventHash, pe);
        return true;
      }
      return false;
    }
    return true;
  }
}
