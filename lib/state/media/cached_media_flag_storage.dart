import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class CachedMediaFlagStorage {
  static const _prefsKey = 'event_ids';

  static final CachedMediaFlagStorage _instance = CachedMediaFlagStorage._internal();
  factory CachedMediaFlagStorage() => _instance;
  CachedMediaFlagStorage._internal();

  final _cachedMediaFlagUpdateController = StreamController<Set<String>>.broadcast();
  Stream<Set<String>> get mediaFlageUpdates => _cachedMediaFlagUpdateController.stream;

  /// Save a single eventId
  Future<void> saveEventId(String eventId) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getStringList(_prefsKey) ?? [];
    if (!current.contains(eventId)) {
      current.add(eventId);
      await prefs.setStringList(_prefsKey, current);
      _cachedMediaFlagUpdateController.sink.add(current.toSet());
    }
  }

  /// Retrieve all eventIds
  Future<Set<String>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getStringList(_prefsKey) ?? [];
    return current.toSet();
  }

  /// Remove a specific eventId
  Future<void> remove(String eventId) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getStringList(_prefsKey) ?? [];
    current.remove(eventId);
    await prefs.setStringList(_prefsKey, current);
    _cachedMediaFlagUpdateController.sink.add(current.toSet());
  }

  /// Clear all eventIds
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey);
    _cachedMediaFlagUpdateController.sink.add({});
  }

  /// Dispose the stream controller
  void dispose() {
    _cachedMediaFlagUpdateController.close();
  }
}
