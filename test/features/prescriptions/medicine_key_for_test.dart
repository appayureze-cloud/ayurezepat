import 'package:doctro_patient/features/prescriptions/presentation/dose_reminder_scheduler.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('medicineKeyFor', () {
    test('extracts the prescription/item key regardless of day/dose', () {
      expect(medicineKeyFor('presc1-item0-day0-dose0'), 'presc1-item0');
      expect(medicineKeyFor('presc1-item0-day5-dose2'), 'presc1-item0');
    });

    test('distinguishes different items of the same prescription', () {
      expect(medicineKeyFor('presc1-item1-day0-dose0'), 'presc1-item1');
    });

    test('returns null for an unrecognized reminder id format', () {
      expect(medicineKeyFor('not-a-local-reminder-id'), isNull);
    });
  });
}
