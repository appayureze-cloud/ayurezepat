import 'package:doctro_patient/features/medicine_reminders/data/mock_medicine_reminder_repository.dart';
import 'package:doctro_patient/features/medicine_reminders/domain/medicine_reminder_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MockMedicineReminderRepository', () {
    late MedicineReminderRepository repository;

    setUp(() {
      repository = MockMedicineReminderRepository();
    });

    test('createReminder returns a non-empty reminder id', () async {
      final id = await repository.createReminder(
        patientId: 'patient-1',
        medicineName: 'Amoxicillin',
        dosage: '500mg',
        frequency: 'Twice daily',
        times: const ['09:00', '21:00'],
        startDate: '2026-01-01',
        endDate: '2026-01-07',
      );

      expect(id, isNotNull);
      expect(id, isNotEmpty);
    });

    test('logAdherence and snooze complete without throwing', () async {
      await repository.logAdherence(reminderId: 'r1', taken: true);
      await repository.snooze(reminderId: 'r1');
    });
  });
}
