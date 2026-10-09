import '../../astra/data/astra_gateway_apis.dart';
import '../../astra/data/astra_gateway_client.dart';
import '../../../const/prefConstatnt.dart';
import '../../../const/preference.dart';
import '../domain/case_repository.dart';
import '../domain/entities/case.dart';

class CaseException implements Exception {
  final String message;
  CaseException(this.message);

  @override
  String toString() => message;
}

/// Talks to the real Astra gateway (astra.ayureze.in), not the main app
/// backend. Astra's own doctor-facing case/create (POST /api/companion/case/create)
/// requires a doctor_id + diagnosis already known, so it can't be used to
/// bootstrap a case before any doctor is involved - case/open
/// (app/companion_api.py's open_patient_case) was added for that instead.
class CaseRepositoryImpl implements CaseRepository {
  final AstraGatewayClient _gateway;

  CaseRepositoryImpl([AstraGatewayClient? gateway])
      : _gateway = gateway ?? AstraGatewayClient();

  @override
  Future<Case> ensureActiveCase() async {
    final cachedId = SharedPreferenceHelper.getString(Preferences.activeCaseId);
    if (cachedId != null && cachedId.isNotEmpty) {
      try {
        final cached = await getCase(cachedId);
        if (cached.isActive) return cached;
      } catch (_) {
        // Cached case is gone or unreadable - fall through to creating a
        // new one rather than blocking the booking flow on it.
      }
    }
    return createCase();
  }

  @override
  Future<Case> getCase(String id) async {
    final dio = await _gateway.dio();
    final response = await dio.get(AstraGatewayApis.companionCaseGet(id));
    final data = response.data as Map<String, dynamic>;
    final caseJson = data['case'] as Map<String, dynamic>?;
    if (caseJson == null) {
      throw CaseException('Case not found');
    }
    return Case.fromJson(caseJson);
  }

  @override
  Future<Case> createCase() async {
    final dio = await _gateway.dio();
    final response = await dio.post(AstraGatewayApis.companionCaseOpen, data: {});
    final data = response.data as Map<String, dynamic>;
    final created = Case.fromJson(data);
    await SharedPreferenceHelper.setString(Preferences.activeCaseId, created.id);
    return created;
  }
}
