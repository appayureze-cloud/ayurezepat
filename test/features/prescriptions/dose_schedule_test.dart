import 'package:doctro_patient/features/prescriptions/domain/dose_schedule.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('timesPerDayFor', () {
    test('recognizes once daily as the default', () {
      expect(timesPerDayFor('Once a day'), 1);
      expect(timesPerDayFor('unrecognized text'), 1);
    });

    test('recognizes twice daily', () {
      expect(timesPerDayFor('Twice daily'), 2);
      expect(timesPerDayFor('2 times a day'), 2);
    });

    test('recognizes thrice daily', () {
      expect(timesPerDayFor('Thrice daily'), 3);
      expect(timesPerDayFor('Three times a day'), 3);
      expect(timesPerDayFor('3 times a day'), 3);
    });

    test('recognizes four times daily', () {
      expect(timesPerDayFor('Four times a day'), 4);
      expect(timesPerDayFor('4 times a day'), 4);
    });

    test('is case-insensitive', () {
      expect(timesPerDayFor('TWICE DAILY'), 2);
    });
  });

  group('defaultDoseTimesFor', () {
    test('once daily gives a single morning dose', () {
      expect(defaultDoseTimesFor(1), [const DoseTime(9, 0)]);
    });

    test('twice daily spreads morning and night', () {
      expect(defaultDoseTimesFor(2),
          [const DoseTime(9, 0), const DoseTime(21, 0)]);
    });

    test('thrice daily spreads across the day', () {
      expect(defaultDoseTimesFor(3),
          [const DoseTime(9, 0), const DoseTime(14, 0), const DoseTime(21, 0)]);
    });

    test('falls back to four evenly-spread doses for anything higher', () {
      expect(defaultDoseTimesFor(4), [
        const DoseTime(8, 0),
        const DoseTime(12, 0),
        const DoseTime(16, 0),
        const DoseTime(20, 0),
      ]);
    });
  });

  group('DoseTime', () {
    test('equality is by hour and minute', () {
      expect(const DoseTime(9, 0), const DoseTime(9, 0));
      expect(const DoseTime(9, 0) == const DoseTime(9, 30), isFalse);
    });

    test('toString pads to two digits', () {
      expect(const DoseTime(9, 5).toString(), '09:05');
    });
  });
}
