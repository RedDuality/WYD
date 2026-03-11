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
      final parts = <String, String>{};
      for (final part in rrule.split(';')) {
        final kv = part.split('=');
        if (kv.length == 2) parts[kv[0]] = kv[1];
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
          final idx = dayNames.indexOf(d);
          if (idx >= 0) byWeekDay.add(idx);
        }
      }

      DateTime? until;
      if (parts['UNTIL'] != null) {
        try {
          final raw = parts['UNTIL']!;
          // Parse YYYYMMDDTHHMMSSZ
          final formatted =
              '${raw.substring(0, 4)}-${raw.substring(4, 6)}-${raw.substring(6, 8)}T${raw.substring(9, 11)}:${raw.substring(11, 13)}:${raw.substring(13, 15)}Z';
          until = DateTime.parse(formatted);
        } catch (_) {}
      }

      return RecurrenceConfig(
        frequency: freq,
        interval: interval,
        byWeekDay: byWeekDay,
        until: until,
      );
    } catch (_) {
      return null;
    }
  }
}
