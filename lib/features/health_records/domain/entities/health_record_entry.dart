/// One entry in a patient's health record timeline (encounters,
/// prescriptions, reports), newest first. See docs/backend/health-records.md.
sealed class HealthRecordEntry {
  final DateTime at;
  const HealthRecordEntry(this.at);
}

class EncounterEntry extends HealthRecordEntry {
  final String doctorName;
  final String? specialty;
  // Astra's case id (a UUID), not a Laravel appointment row id - the real
  // backend for this timeline is Astra's own case data, which has no
  // concept of a Laravel appointment at all. Kept as `appointmentId` to
  // match the documented contract's field name.
  final String appointmentId;

  const EncounterEntry({
    required DateTime at,
    required this.doctorName,
    required this.appointmentId,
    this.specialty,
  }) : super(at);
}

class PrescriptionEntry extends HealthRecordEntry {
  // Astra's prescription id (e.g. "PRES-..."), not a Laravel row id - see
  // the note on EncounterEntry.appointmentId above.
  final String prescriptionId;
  final String appointmentId;
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
