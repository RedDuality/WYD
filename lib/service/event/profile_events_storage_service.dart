import 'package:wyd_front/API/Event/event_api.dart';
import 'package:wyd_front/model/profile_event.dart';
import 'package:wyd_front/state/profileEvent/profile_events_storage.dart';

class ProfileEventsStorageService {
  static Future<Set<ProfileEvent>> retrieveFromServer(String eventHash) async {
    return await EventAPI().retriveProfileEvents(eventHash);
  }

  static Future<bool> confirm(String eventHash, bool confirmed, String profileHash) async {
    var pe = await ProfileEventsStorage().getSingle(eventHash, profileHash);

    if (pe == null) return true;
    if (pe.confirmed == confirmed) return false;

    pe.confirmed = confirmed;
    ProfileEventsStorage().update(pe);
    return true;
  }
}
