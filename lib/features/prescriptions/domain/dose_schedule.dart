/// A clock time of day, independent of Flutter (so this domain logic is
/// plain-Dart testable without a widget test).
class DoseTime {
  final int hour;
  final int minute;
  const DoseTime(this.hour, this.minute);

  @override
  bool operator ==(Object other) =>
      other is DoseTime && other.hour == hour && other.minute == minute;

  @override
  int get hashCode => Object.hash(hour, minute);

  @override
  String toString() =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
}

/// Best-effort parse of a prescription's free-text `frequency` field (e.g.
/// "Twice daily", "Once a day", "Thrice daily", "Four times a day") into a
/// times-per-day count. Defaults to once daily for anything unrecognized -
/// under-reminding is safer than scheduling a guessed high frequency.
int timesPerDayFor(String frequency) {
  final normalized = frequency.toLowerCase();
  if (normalized.contains('four') || normalized.contains('4 times')) {
    return 4;
  }
  if (normalized.contains('thrice') ||
      normalized.contains('three times') ||
      normalized.contains('3 times')) {
    return 3;
  }
  if (normalized.contains('twice') ||
      normalized.contains('two times') ||
      normalized.contains('2 times')) {
    return 2;
  }
  return 1;
}

/// Sensible default clock times for a given number of daily doses, spread
/// across waking hours. The patient isn't given a way to customize these
/// yet - a reasonable default beats no reminder at all, but this is the
/// first thing to make editable if patients ask for it.
List<DoseTime> defaultDoseTimesFor(int timesPerDay) => switch (timesPerDay) {
      1 => const [DoseTime(9, 0)],
      2 => const [DoseTime(9, 0), DoseTime(21, 0)],
      3 => const [DoseTime(9, 0), DoseTime(14, 0), DoseTime(21, 0)],
      _ => const [
          DoseTime(8, 0),
          DoseTime(12, 0),
          DoseTime(16, 0),
          DoseTime(20, 0),
        ],
    };
