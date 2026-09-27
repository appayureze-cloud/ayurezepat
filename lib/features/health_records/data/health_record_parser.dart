import '../domain/entities/health_record_entry.dart';

/// Hand-written (not json_serializable): the response is a discriminated
/// union keyed by `type`, which doesn't map cleanly onto a single
/// generated class.
HealthRecordEntry? parseHealthRecordEntry(Map<String, dynamic> json) {
  final type = json['type'] as String?;
  final at = DateTime.tryParse(json['at'] as String? ?? '');
  if (at == null) return null;

  switch (type) {
    case 'encounter':
      return EncounterEntry(
        at: at,
        doctorName: json['doctor_name'] as String? ?? '',
        appointmentId: json['appointment_id'] as int? ?? 0,
        specialty: json['specialty'] as String?,
      );
    case 'prescription':
      return PrescriptionEntry(
        at: at,
        prescriptionId: json['prescription_id'] as int? ?? 0,
        appointmentId: json['appointment_id'] as int? ?? 0,
        doctorName: json['doctor_name'] as String? ?? '',
      );
    case 'report':
      return ReportEntry(
        at: at,
        title: json['title'] as String? ?? 'Report',
        url: json['url'] as String? ?? '',
      );
    default:
      return null;
  }
}

class HealthRecordTimelineResponse {
  final bool success;
  final String? msg;
  final List<HealthRecordEntry> entries;

  HealthRecordTimelineResponse({
    required this.success,
    this.msg,
    required this.entries,
  });

  factory HealthRecordTimelineResponse.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] as List<dynamic>? ?? [])
        .map((e) => parseHealthRecordEntry(e as Map<String, dynamic>))
        .whereType<HealthRecordEntry>()
        .toList()
      ..sort((a, b) => b.at.compareTo(a.at));
    return HealthRecordTimelineResponse(
      success: json['success'] as bool? ?? false,
      msg: json['msg'] as String?,
      entries: data,
    );
  }
}
