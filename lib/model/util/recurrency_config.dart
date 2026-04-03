import 'package:rrule/rrule.dart';

extension RecurrenceRuleX on RecurrenceRule {
  /// Returns a human-readable description of the recurrence rule.
  /// e.g. "Weekly on Mon, Wed", "Every 2 weeks until 31/12/2025"
  String toHumanReadable() {
    final effectiveInterval = interval ?? 1;

    String freqCapitalized;
    String freqPlural;
    switch (frequency) {
      case Frequency.daily:
        freqCapitalized = 'Daily';
        freqPlural = 'days';
        break;
      case Frequency.weekly:
        freqCapitalized = 'Weekly';
        freqPlural = 'weeks';
        break;
      case Frequency.monthly:
        freqCapitalized = 'Monthly';
        freqPlural = 'months';
        break;
      case Frequency.yearly:
        freqCapitalized = 'Yearly';
        freqPlural = 'years';
        break;
      default:
        freqCapitalized = frequency.toString().toUpperCase() + frequency.toString().substring(1).toLowerCase();
        freqPlural = '${frequency.toString().toLowerCase()}s';
    }

    String description = effectiveInterval == 1
        ? freqCapitalized
        : 'Every $effectiveInterval $freqPlural';

    if (frequency == Frequency.weekly && byWeekDays.isNotEmpty) {
      const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      final sorted = byWeekDays.map((e) => e.day).toList()..sort();
      description += ' on ${sorted.map((d) => dayNames[d - 1]).join(', ')}';
    }

    if (until != null && until!.isBefore(DateTime(9999, 1, 1))) {
      final d = until!.toLocal();
      final dateStr =
          '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
      description += ' until $dateStr';
    }

    return description;
  }
}