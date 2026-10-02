import 'package:doctro_patient/features/health_records/data/health_record_parser.dart';
import 'package:doctro_patient/features/health_records/domain/entities/health_record_entry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('parseHealthRecordEntry', () {
    test('parses an encounter entry', () {
      final entry = parseHealthRecordEntry({
        'type': 'encounter',
        'at': '2026-09-20T10:00:00Z',
        'appointment_id': 1,
        'doctor_name': 'Dr. Anita Rao',
        'specialty': 'General Medicine',
      });

      expect(entry, isA<EncounterEntry>());
      expect((entry as EncounterEntry).doctorName, 'Dr. Anita Rao');
    });

    test('parses a prescription entry', () {
      final entry = parseHealthRecordEntry({
        'type': 'prescription',
        'at': '2026-09-20T10:20:00Z',
        'prescription_id': 1,
        'appointment_id': 1,
        'doctor_name': 'Dr. Anita Rao',
      });

      expect(entry, isA<PrescriptionEntry>());
    });

    test('parses a report entry', () {
      final entry = parseHealthRecordEntry({
        'type': 'report',
        'at': '2026-09-18T09:00:00Z',
        'title': 'Blood test',
        'url': 'https://example.com/report.pdf',
      });

      expect(entry, isA<ReportEntry>());
    });

    test('returns null for an unrecognized type instead of throwing', () {
      final entry = parseHealthRecordEntry({
        'type': 'something_new',
        'at': '2026-09-18T09:00:00Z',
      });

      expect(entry, isNull);
    });

    test('returns null when at is missing/unparseable', () {
      final entry = parseHealthRecordEntry({'type': 'encounter'});
      expect(entry, isNull);
    });
  });

  group('HealthRecordTimelineResponse', () {
    test('sorts entries newest first', () {
      final response = HealthRecordTimelineResponse.fromJson({
        'success': true,
        'data': [
          {
            'type': 'report',
            'at': '2026-01-01T00:00:00Z',
            'title': 'Old',
            'url': 'u'
          },
          {
            'type': 'report',
            'at': '2026-06-01T00:00:00Z',
            'title': 'New',
            'url': 'u'
          },
        ],
      });

      expect(response.entries, hasLength(2));
      expect((response.entries.first as ReportEntry).title, 'New');
    });
  });
}
