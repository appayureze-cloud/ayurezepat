/// One entry in a patient's health record timeline (encounters,
/// prescriptions, reports), newest first. See docs/backend/health-records.md.
sealed class HealthRecordEntry {
  final DateTime at;
  const HealthRecordEntry(this.at);
}

class EncounterEntry extends HealthRecordEntry {
  final String doctorName;
  final String? specialty;
  final int appointmentId;

  const EncounterEntry({
    required DateTime at,
    required this.doctorName,
    required this.appointmentId,
    this.specialty,
  }) : super(at);
}

class PrescriptionEntry extends HealthRecordEntry {
  final int prescriptionId;
  final int appointmentId;
  final String doctorName;

  const PrescriptionEntry({
    required DateTime at,
    required this.prescriptionId,
    required this.appointmentId,
    required this.doctorName,
  }) : super(at);
}

class ReportEntry extends HealthRecordEntry {
  final String title;
  final String url;

  const ReportEntry({
    required DateTime at,
    required this.title,
    required this.url,
  }) : super(at);
}
