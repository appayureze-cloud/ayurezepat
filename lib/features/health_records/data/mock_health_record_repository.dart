import '../domain/entities/health_record_entry.dart';
import '../domain/health_record_repository.dart';

class MockHealthRecordRepository implements HealthRecordRepository {
  @override
  Future<List<HealthRecordEntry>> getTimeline(String caseId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final now = DateTime.now();
    return [
      EncounterEntry(
        at: now.subtract(const Duration(days: 1)),
        doctorName: 'Dr. Anita Rao',
        specialty: 'General Medicine',
        appointmentId: 1,
      ),
      PrescriptionEntry(
        at: now.subtract(const Duration(days: 1)),
        prescriptionId: 1,
        appointmentId: 1,
        doctorName: 'Dr. Anita Rao',
      ),
      EncounterEntry(
        at: now.subtract(const Duration(days: 10)),
        doctorName: 'Dr. Vikram Shah',
        specialty: 'Ayurveda',
        appointmentId: 2,
      ),
    ];
  }
}
