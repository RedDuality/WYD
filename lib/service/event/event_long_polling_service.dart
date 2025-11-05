import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wyd_front/service/event/event_retrieve_service.dart';

class EventLongPollingService {
  // singleton cos static
  static Timer? _pollingTimer;
  static bool _ongoingCheck = false;

  static const Duration _pollingInterval = Duration(minutes: 1);

  static void resumePolling() {
    if (_pollingTimer?.isActive == true) return;
    _scheduleNextCheck();
  }

  static void _scheduleNextCheck() async {
    final lastCheckedTime = await _loadLastCheckedTime();
    final now = DateTime.now().toUtc();
    final nextDue = lastCheckedTime.add(_pollingInterval);

    final delay = nextDue.isAfter(now) ? nextDue.difference(now) : Duration.zero;

    _pollingTimer = Timer(delay, () async {
      await checkForUpdatedEvent(now);
      _scheduleNextCheck();
    });

    debugPrint('Next poll scheduled in $delay');
  }

  /// Stops the polling timer. Called when the app/tab loses focus.
  static void pausePolling() {
    if (_pollingTimer?.isActive == true) {
      _pollingTimer!.cancel();
      debugPrint('EventLongPollingService paused.');
    }
    _pollingTimer = null;
  }

  static Future<void> checkForUpdatedEvent(DateTime now) async {
    // Ensure only one check process is running at a time, if the request is taking longer then _pollingInterval
    if (_ongoingCheck) {
      debugPrint('checkForPhotos is already running. Skipping this poll.');
      return;
    }

    _ongoingCheck = true;

    try {
      final lastCheckedTime = await _loadLastCheckedTime();

      await EventRetrieveService.checkEventUpdatesAfter(lastCheckedTime);

      // Only save the current time if the retrieval was successful
      await _saveLastCheckedTime(now);
    } catch (e) {
      debugPrint("Error during Event Long Polling check: $e");
    } finally {
      _ongoingCheck = false;
    }
  }

  /// Save DateTime to SharedPreferences
  static Future<void> _saveLastCheckedTime(DateTime time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('eventLongPollingLastTime', (time.toUtc().toIso8601String()));
  }

  /// Load DateTime from SharedPreferences
  static Future<DateTime> _loadLastCheckedTime() async {
    final prefs = await SharedPreferences.getInstance();
    final dateTimeString = prefs.getString('eventLongPollingLastTime');
    if (dateTimeString != null) {
      try {
        return DateTime.parse(dateTimeString).toUtc();
      } catch (e) {
        debugPrint("Error while converting last long polled time value: $e");
      }
    }
    return DateTime.now().toUtc(); // events are being retrieved by the eventRetrieveService
  }
}
