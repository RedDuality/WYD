import 'package:wyd_front/API/Event/event_api.dart';
import 'package:wyd_front/model/profile_event.dart';
import 'package:wyd_front/state/profileEvent/profile_events_storage.dart';

// Assuming ProfileEvent and EventRole are defined elsewhere
class ProfileEventsStorageService {

  Future<void> saveSingle(String eventHash, ProfileEvent profileEvent) async {
    return await ProfileEventStorage().saveSingle(eventHash, profileEvent);
  }

  Future<void> saveMultiple(String eventHash, Set<ProfileEvent> newProfileEvents) async {
    return await ProfileEventStorage().saveMultiple(eventHash, newProfileEvents);
  }

  Future<ProfileEvent?> getSingle(String eventHash, String profileHash) async {
    return await ProfileEventStorage().getSingle(eventHash, profileHash);
  }

  Future<Set<ProfileEvent>> getAll(String eventHash) async {
    return await ProfileEventStorage().getAll(eventHash);
  }


  Future<Set<ProfileEvent>> retrieveFromServer(String eventHash)  async {
    var profiles = await EventAPI().retriveProfileEvents(eventHash);

    return profiles;
  }

  Future<void> removeSingle(String eventHash, String profileHash) async {
    return await ProfileEventStorage().removeSingle(eventHash, profileHash);
  }

  Future<void> removeAll(String eventHash) async {
    return await ProfileEventStorage().removeAll(eventHash);
  }

  Future<bool> confirm(String eventHash, bool confirmed, String profileHash) async {
    var pe = await getSingle(eventHash, profileHash);
    if (pe != null) {
      if (pe.confirmed != confirmed) {
        pe.confirmed = confirmed;
        saveSingle(eventHash, pe);
        return true;
      }
      return false; // no need to update
    }
    return true;
  }
}
