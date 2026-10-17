import '../../../const/env.dart';
import '../domain/entities/health_record_entry.dart';
import '../domain/health_record_repository.dart';
import 'health_record_repository_impl.dart';
import 'mock_health_record_repository.dart';

class HealthRecordService {
  final HealthRecordRepository _repository;

  HealthRecordService(this._repository);

  /// No Dio parameter: the real repository talks to the Astra gateway
  /// (its own auth/host), not the main app backend's client.
  factory HealthRecordService.create() => HealthRecordService(
        Env.useMockHealthRecords
            ? MockHealthRecordRepository()
            : HealthRecordRepositoryImpl(),
      );

  Future<List<HealthRecordEntry>> getTimeline(String caseId) =>
      _repository.getTimeline(caseId);
}
