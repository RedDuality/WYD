import 'package:flutter/material.dart';

enum RecurrenceFrequency { daily, weekly, monthly, yearly }

class RecurrenceConfig {
  final RecurrenceFrequency frequency;
  final int interval;
  final List<int> byWeekDay; // For weekly: 0=Mon, 1=Tue, ... 6=Sun
  final DateTime? until;

  const RecurrenceConfig({
    required this.frequency,
    this.interval = 1,
    this.byWeekDay = const [],
    this.until,
  });

  String toRRule() {
    final freqMap = {
      RecurrenceFrequency.daily: 'DAILY',
      RecurrenceFrequency.weekly: 'WEEKLY',
      RecurrenceFrequency.monthly: 'MONTHLY',
      RecurrenceFrequency.yearly: 'YEARLY',
    };

    final parts = <String>['FREQ=${freqMap[frequency]}'];

    if (interval > 1) parts.add('INTERVAL=$interval');

    if (frequency == RecurrenceFrequency.weekly && byWeekDay.isNotEmpty) {
      const dayNames = ['MO', 'TU', 'WE', 'TH', 'FR', 'SA', 'SU'];
      final days = byWeekDay.map((d) => dayNames[d]).join(',');
      parts.add('BYDAY=$days');
    }

    if (until != null) {
      final untilStr = '${until!.toUtc().toIso8601String().replaceAll(RegExp(r'[-:]'), '').split('.')[0]}Z';
      parts.add('UNTIL=$untilStr');
    }

    return parts.join(';');
  }

  static RecurrenceConfig? fromRRule(String? rrule) {
    if (rrule == null || rrule.isEmpty) return null;

    try {
      // 1. Clean the string: Remove "RRULE:" prefix and trim whitespace
      String cleanRrule = rrule.replaceFirst('RRULE:', '').trim();
      
      final parts = <String, String>{};
      for (final part in cleanRrule.split(';')) {
        final kv = part.split('=');
        if (kv.length == 2) {
          // Trim both key and value to handle accidental spaces
          parts[kv[0].trim().toUpperCase()] = kv[1].trim();
        }
      }

      final freqStr = parts['FREQ'];
      if (freqStr == null) return null;

      final freqMap = {
        'DAILY': RecurrenceFrequency.daily,
        'WEEKLY': RecurrenceFrequency.weekly,
        'MONTHLY': RecurrenceFrequency.monthly,
        'YEARLY': RecurrenceFrequency.yearly,
      };

      final freq = freqMap[freqStr];
      if (freq == null) return null;

      final interval = int.tryParse(parts['INTERVAL'] ?? '1') ?? 1;

      final List<int> byWeekDay = [];
      if (parts['BYDAY'] != null) {
        const dayNames = ['MO', 'TU', 'WE', 'TH', 'FR', 'SA', 'SU'];
        for (final d in parts['BYDAY']!.split(',')) {
          // Handle cases like "1TH" or "-1SU" by taking the last two chars
          final dayOnly = d.length > 2 ? d.substring(d.length - 2) : d;
          final idx = dayNames.indexOf(dayOnly.toUpperCase());
          if (idx >= 0) byWeekDay.add(idx);
        }
      }

      DateTime? until;
      final rawUntil = parts['UNTIL'];
      if (rawUntil != null) {
        try {
          // More robust date parsing
          if (rawUntil.length >= 8) {
            final year = rawUntil.substring(0, 4);
            final month = rawUntil.substring(4, 6);
            final day = rawUntil.substring(6, 8);
            
            if (rawUntil.contains('T')) {
              final hour = rawUntil.substring(9, 11);
              final min = rawUntil.substring(11, 13);
              final sec = rawUntil.substring(13, 15);
              until = DateTime.parse('$year-$month-${day}T$hour:$min:${sec}Z');
            } else {
              until = DateTime.parse('$year-$month-$day');
            }
          }
        } catch (e) {
          debugPrint("Error parsing UNTIL: $e");
        }
      }

      return RecurrenceConfig(
        frequency: freq,
        interval: interval,
        byWeekDay: byWeekDay,
        until: until,
      );
    } catch (e) {
      debugPrint("General RRule parsing error: $e");
      return null;
    }
  }

  // Add this method inside the RecurrenceConfig class
  String toHumanReadable() {
    final freqLabels = {
      RecurrenceFrequency.daily: 'day',
      RecurrenceFrequency.weekly: 'week',
      RecurrenceFrequency.monthly: 'month',
      RecurrenceFrequency.yearly: 'year',
    };

    String description = "";

    // 1. Handle Interval and Frequency
    if (interval == 1) {
      description = "${frequency.name[0].toUpperCase()}${frequency.name.substring(1)}";
    } else {
      description = "Every $interval ${freqLabels[frequency]}s";
    }

    // 2. Handle Weekdays (for Weekly)
    if (frequency == RecurrenceFrequency.weekly && byWeekDay.isNotEmpty) {
      const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      final selectedDays = byWeekDay.map((d) => dayNames[d]).join(', ');
      description += " on $selectedDays";
    }

    // 3. Handle End Date
    if (until != null) {
      final dateStr =
          "${until!.day.toString().padLeft(2, '0')}/${until!.month.toString().padLeft(2, '0')}/${until!.year}";
      description += " until $dateStr";
    }

    return description;
  }
}
