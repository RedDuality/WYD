import 'package:wyd_front/API/Event/event_api.dart';
import 'package:wyd_front/model/profile_event.dart';
import 'package:wyd_front/state/profileEvent/profile_events_cache.dart';
import 'package:wyd_front/state/profileEvent/profile_events_storage.dart';

// Assuming ProfileEvent and EventRole are defined elsewhere
class ProfileEventsStorageService {

  Future<ProfileEvent?> getSingle(String eventHash, String profileHash) async {
    return await ProfileEventsStorage().getSingle(eventHash, profileHash);
  }

  Future<Set<ProfileEvent>> getAll(String eventHash) async {
    return await ProfileEventsStorage().getAll(eventHash);
  }

  Future<Set<ProfileEvent>> retrieveFromServer(String eventHash) async {
    var profiles = await EventAPI().retriveProfileEvents(eventHash);

    return profiles;
  }

  Future<void> removeSingle(String eventId, String profileId) async {
    ProfileEventsCache().removeSingle(eventId, profileId);
    return await ProfileEventsStorage().removeSingle(eventId, profileId);
  }

  Future<void> removeAll(String eventHash) async {
    return await ProfileEventsStorage().removeAll(eventHash);
  }

  Future<bool> confirm(String eventHash, bool confirmed, String profileHash) async {
    var pe = await getSingle(eventHash, profileHash);
    if (pe != null) {
      if (pe.confirmed != confirmed) {
        pe.confirmed = confirmed;
        ProfileEventsStorage().saveSingle(pe);
        return true;
      }
      return false; // no need to update
    }
    return true;
  }
}
