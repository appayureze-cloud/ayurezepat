import 'package:dio/dio.dart';

import '../../../const/env.dart';
import '../domain/entities/health_record_entry.dart';
import '../domain/health_record_repository.dart';
import 'health_record_repository_impl.dart';
import 'mock_health_record_repository.dart';

class HealthRecordService {
  final HealthRecordRepository _repository;

  HealthRecordService(this._repository);

  factory HealthRecordService.withDio(Dio dio) => HealthRecordService(
        Env.useMockHealthRecords
            ? MockHealthRecordRepository()
            : HealthRecordRepositoryImpl(dio),
      );

  Future<List<HealthRecordEntry>> getTimeline(String caseId) =>
      _repository.getTimeline(caseId);
}
