import 'package:dio/dio.dart';

import '../../../api/network_api.dart';
import '../domain/entities/health_record_entry.dart';
import '../domain/health_record_repository.dart';

class HealthRecordRepositoryImpl implements HealthRecordRepository {
  final Dio dio;

  HealthRecordRepositoryImpl(this.dio);

  @override
  Future<List<HealthRecordEntry>> getTimeline(String caseId) async {
    final response = await RestClient(dio).getHealthRecordTimeline(caseId);
    return response.entries;
  }
}
