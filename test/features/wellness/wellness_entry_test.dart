import 'package:doctro_patient/features/wellness/domain/entities/wellness_entry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WellnessEntry.dateKeyFor', () {
    test('zero-pads month and day', () {
      expect(WellnessEntry.dateKeyFor(DateTime(2026, 1, 5)), '2026-01-05');
    });

    test('does not zero-pad the year', () {
      expect(WellnessEntry.dateKeyFor(DateTime(2026, 12, 25)), '2026-12-25');
    });
  });

  group('WellnessEntry.copyWith', () {
    test('keeps existing fields untouched when not overridden', () {
      final entry = WellnessEntry(
        dateKey: '2026-01-01',
        sleepHours: 7,
        movementMinutes: 30,
        updatedAt: '2026-01-01T00:00:00.000',
      );
      final updated = entry.copyWith(movementMinutes: 45);

      expect(updated.sleepHours, 7);
      expect(updated.movementMinutes, 45);
      expect(updated.dateKey, '2026-01-01');
    });
  });

  group('WellnessEntry JSON round-trip', () {
    test('toJson/fromJson preserves every field', () {
      final entry = WellnessEntry(
        dateKey: '2026-02-10',
        sleepHours: 6.5,
        movementMinutes: 20,
        relaxationMinutes: 15,
        mood: 4,
        note: 'felt good',
        updatedAt: '2026-02-10T08:00:00.000',
      );

      final roundTripped = WellnessEntry.fromJson(entry.toJson());

      expect(roundTripped.dateKey, entry.dateKey);
      expect(roundTripped.sleepHours, entry.sleepHours);
      expect(roundTripped.movementMinutes, entry.movementMinutes);
      expect(roundTripped.relaxationMinutes, entry.relaxationMinutes);
      expect(roundTripped.mood, entry.mood);
      expect(roundTripped.note, entry.note);
    });
  });
}
