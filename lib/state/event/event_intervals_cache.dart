import 'package:wyd_front/state/event/event_intervals_storage.dart';
import 'package:wyd_front/state/util/intervals_cache.dart';

class EventIntervalsCache extends IntervalsCache<EventIntervalsStorage> {
  static final EventIntervalsCache _instance = EventIntervalsCache._internal(EventIntervalsStorage());
  factory EventIntervalsCache() => _instance;
  EventIntervalsCache._internal(super.storage);
}
