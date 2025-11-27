import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class MediaFlagStorage {
  static const _prefsKey = 'event_ids';

  static final MediaFlagStorage _instance = MediaFlagStorage._internal();
  factory MediaFlagStorage() => _instance;
  MediaFlagStorage._internal();

  final _cachedMediaFlagUpdateController = StreamController<(String eventId, bool deleted)>();
  Stream<(String eventId, bool deleted)> get mediaFlagsUpdates => _cachedMediaFlagUpdateController.stream;

  final _clearAllChannel = StreamController<void>();
  Stream<void> get clearChannel => _clearAllChannel.stream;

  /// Save a single eventId
  Future<void> saveEventId(String eventId) async {
    _cachedMediaFlagUpdateController.sink.add((eventId, false));

    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getStringList(_prefsKey) ?? [];
    if (!current.contains(eventId)) {
      current.add(eventId);
      await prefs.setStringList(_prefsKey, current);
    }
  }

  /// Remove a specific eventId
  Future<void> remove(String eventId) async {
    _cachedMediaFlagUpdateController.sink.add((eventId, true));

    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getStringList(_prefsKey) ?? [];
    current.remove(eventId);
    await prefs.setStringList(_prefsKey, current);
  }

  /// Retrieve all eventIds
  Future<Set<String>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getStringList(_prefsKey) ?? [];
    return current.toSet();
  }

  /// Clear all eventIds
  Future<void> clearAll() async {
    _clearAllChannel.sink.add(null);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey);
  }
}
