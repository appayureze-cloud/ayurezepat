/// The real backend for this - `/api/v1/api/reminders/*` on the Astra
/// gateway (astra.ayureze.in) - is a *server-side*, WhatsApp-notifying
/// reminder system, separate from this app's fully local,
/// flutter_local_notifications-based dose reminders
/// (`lib/features/prescriptions/presentation/dose_reminder_scheduler.dart`).
/// This repository is wired alongside the local scheduler, not instead of
/// it - see the call site in dose_reminder_scheduler.dart. Gated by
/// `Env.useMockServerReminders`, mocked by default.
abstract class MedicineReminderRepository {
  /// Registers a reminder covering the medicine's whole course (not one
  /// call per dose). Returns the server's reminder id if the response
  /// included one in a recognizable shape - the real endpoint's response
  /// schema isn't fixed in its published OpenAPI spec, so this is a
  /// best-effort parse, not a guarantee.
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
  });

  Future<void> logAdherence({required String reminderId, required bool taken});

  Future<void> snooze({required String reminderId, int minutes = 30});
}
