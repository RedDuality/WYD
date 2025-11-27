import 'package:wyd_front/API/Event/event_api.dart';
import 'package:wyd_front/model/profiles/profile_event.dart';
import 'package:wyd_front/state/profileEvent/detailed_profile_events_storage.dart';

class ProfileEventsStorageService {
  static Future<Set<ProfileEvent>> retrieveFromServer(String eventId) async {
    return await EventAPI().retriveProfileEvents(eventId);
  }

  static Future<bool> confirm(String eventId, bool confirmed, String profileHash) async {
    var pe = await DetailedProfileEventsStorage().getSingle(eventId, profileHash);

    if (pe == null) return true;
    if (pe.confirmed == confirmed) return false;

    pe.confirmed = confirmed;
    DetailedProfileEventsStorage().update(pe);
    return true;
  }
}
