import 'dart:math';

import '../domain/medicine_reminder_repository.dart';

/// Stands in for the real Supabase-backed reminders API until
/// Env.useMockServerReminders is flipped. See docs/backend/astra.md.
class MockMedicineReminderRepository implements MedicineReminderRepository {
  final Random _random = Random();

  @override
  Future<String?> createReminder({
    required String patientId,
    String? patientName,
    String? patientPhone,
    required String medicineName,
    required String dosage,
    required String frequency,
    required List<String> times,
    required String startDate,
    required String endDate,
    String? instructions,
    bool enableWhatsapp = true,
  }) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return 'mock_reminder_${_random.nextInt(1 << 32)}';
  }

  @override
  Future<void> logAdherence({
    required String reminderId,
    required bool taken,
  }) async {
    await Future.delayed(const Duration(milliseconds: 50));
  }

  @override
  Future<void> snooze({required String reminderId, int minutes = 30}) async {
    await Future.delayed(const Duration(milliseconds: 50));
  }
}
