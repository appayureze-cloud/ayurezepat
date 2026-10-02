import '../../../const/env.dart';
import '../data/medicine_reminder_repository_impl.dart';
import '../data/mock_medicine_reminder_repository.dart';
import '../domain/medicine_reminder_repository.dart';

/// Resolves the real vs mock MedicineReminderRepository, the same pattern
/// as CaseService/AstraService.
class MedicineReminderService {
  final MedicineReminderRepository _repository;

  MedicineReminderService(this._repository);

  factory MedicineReminderService.create() => MedicineReminderService(
        Env.useMockServerReminders
            ? MockMedicineReminderRepository()
            : MedicineReminderRepositoryImpl(),
      );

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
  }) =>
      _repository.createReminder(
        patientId: patientId,
        patientName: patientName,
        patientPhone: patientPhone,
        medicineName: medicineName,
        dosage: dosage,
        frequency: frequency,
        times: times,
        startDate: startDate,
        endDate: endDate,
        instructions: instructions,
        enableWhatsapp: enableWhatsapp,
      );

  Future<void> logAdherence(
          {required String reminderId, required bool taken}) =>
      _repository.logAdherence(reminderId: reminderId, taken: taken);

  Future<void> snooze({required String reminderId, int minutes = 30}) =>
      _repository.snooze(reminderId: reminderId, minutes: minutes);
}
