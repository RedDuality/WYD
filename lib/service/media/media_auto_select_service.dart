import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wyd_front/model/event.dart';
import 'package:wyd_front/service/event/event_storage_service.dart';
import 'package:wyd_front/service/media/media_retrieve_service.dart';
import 'package:wyd_front/state/profileEvent/profile_events_storage.dart';

class MediaAutoSelectService {
  static Future<void> checkEventsForPhotos() async {
    final now = DateTime.now().toUtc();
    final lastCheckedTime = await _loadLastCheckedTime();

    // Get all events that ended since last check
    final sinceLastTime = DateTimeRange(start: lastCheckedTime, end: now);
    final eventsNotChecked = await _retrieveConfirmedEventsEndedIn(sinceLastTime);

    for (final event in eventsNotChecked) {
      await MediaRetrieveService.retrieveShootedPhotos(event.id);
    }

    await _saveDateTime(time: now);
  }

  static Future<Set<Event>> _retrieveConfirmedEventsEndedIn(DateTimeRange requestedInterval) async {
    final eventsNotChecked = await EventStorageService.retrieveEventsEndedIn(requestedInterval);
    final confirmedEventIds =
        await ProfileEventsStorage().eventsWithProfilesConfirmed(eventsNotChecked.map((event) => event.id).toSet());

    return eventsNotChecked.where((event) => confirmedEventIds.contains(event.id)).toSet();
  }

  /// Save DateTime to SharedPreferences
  static Future<void> _saveDateTime({DateTime? time}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('savedDateTime', (time ?? DateTime.now()).toUtc().toIso8601String());
  }

  /// Load DateTime from SharedPreferences
  static Future<DateTime> _loadLastCheckedTime() async {
    final prefs = await SharedPreferences.getInstance();
    final dateTimeString = prefs.getString('savedDateTime');
    if (dateTimeString != null) {
      try {
        return DateTime.parse(dateTimeString).toUtc();
      } catch (e) {
        debugPrint("Error while converting last checked time value");
      }
    }
    return DateTime.now().subtract(Duration(days: 7)).toUtc();
  }
}
