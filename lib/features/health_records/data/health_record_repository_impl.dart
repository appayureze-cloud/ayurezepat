import '../../astra/data/astra_gateway_apis.dart';
import '../../astra/data/astra_gateway_client.dart';
import '../domain/entities/health_record_entry.dart';
import '../domain/health_record_repository.dart';
import 'health_record_parser.dart';

/// Talks to the real Astra gateway's case health-records endpoint
/// (GET /api/companion/case/{caseId}/health_records), not the main app
/// backend - the originally speculated `{Apis.baseUrl}cases/{caseId}/health_records`
/// (Laravel) route was never built, but every piece of data this timeline
/// needs already lives in Astra's own case/prescription/document tables,
/// so the real backend was added there instead (see
/// app/companion_api.py's get_case_health_records).
class HealthRecordRepositoryImpl implements HealthRecordRepository {
  final AstraGatewayClient _gateway;

  HealthRecordRepositoryImpl([AstraGatewayClient? gateway])
      : _gateway = gateway ?? AstraGatewayClient();

  @override
  Future<List<HealthRecordEntry>> getTimeline(String caseId) async {
    final dio = await _gateway.dio();
    final response =
        await dio.get(AstraGatewayApis.companionCaseHealthRecords(caseId));
    final parsed = HealthRecordTimelineResponse.fromJson(response.data);
    return parsed.entries;
  }
}
