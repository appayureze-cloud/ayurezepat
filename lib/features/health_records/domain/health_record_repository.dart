import 'entities/health_record_entry.dart';

abstract class HealthRecordRepository {
  /// Newest first.
  Future<List<HealthRecordEntry>> getTimeline(String caseId);
}
