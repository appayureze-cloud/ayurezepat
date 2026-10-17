import '../../astra/data/astra_gateway_apis.dart';
import '../../astra/data/astra_gateway_client.dart';
import '../../astra/data/astra_gateway_dtos.dart';
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

CaseStatus _caseStatusFromJourneyStatus(String? status) {
  switch (status) {
    case 'resolved':
      return CaseStatus.resolved;
    case 'closed':
    case 'completed':
      return CaseStatus.closed;
    default:
      return CaseStatus.open;
  }
}

/// Talks to the real Astra gateway (astra.ayureze.in's app/companion_api.py,
/// read directly to settle this), not the main app backend.
///
/// This used to POST to a fictitious `/api/companion/case/open` - that route
/// never existed; it only ever appeared to work because it collided with
/// the `GET /case/{case_id}` pattern (case_id="open"), which is why POST
/// returned 405 and GET returned a generic "Case not found" 404, live,
/// every time. The real `POST /api/companion/case/create` requires a
/// `doctor_id` and `diagnosis` (see `CreateCaseRequest` in companion_api.py)
/// - it's a clinician's output, not something that exists before a doctor
/// has seen the patient, so it can't back this generic
/// "which concern thread is this" lookup that bookings/orders/reminders/
/// therapy all call before any doctor is assigned.
///
/// `Journey` (`POST /api/companion/journey/start`, `GET
/// /api/companion/journey/{id}`) is the real, live concept that actually
/// matches: patient-initiated, no doctor required. This repository is
/// backed by it under the hood while keeping the app's existing `Case`
/// vocabulary (and the `active_case_id` preference key) so none of its
/// nine call sites need to change. The real, doctor-bound case created at
/// booking time (see `linkAppointmentToAstra` in astra_consultation_link.dart)
/// is a separate, richer record once a doctor is actually assigned.
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
        // Cached journey is gone or unreadable - fall through to creating a
        // new one rather than blocking the booking flow on it.
      }
    }
    return createCase();
  }

  @override
  Future<Case> getCase(String id) async {
    final dio = await _gateway.dio();
    final response = await dio.get(AstraGatewayApis.companionJourneyGet(id));
    final data = response.data as Map<String, dynamic>;
    final journeyJson = data['journey'] as Map<String, dynamic>?;
    if (journeyJson == null) {
      throw CaseException('Case not found');
    }
    return Case(
      id: journeyJson['journey_id'] as String? ?? journeyJson['id'] as String,
      status: _caseStatusFromJourneyStatus(journeyJson['status'] as String?),
      createdAt: journeyJson['created_at'] as String?,
      specialty: journeyJson['health_concern'] as String?,
    );
  }

  @override
  Future<Case> createCase() async {
    final dio = await _gateway.dio();
    final patientId = _gateway.cachedUserId;
    if (patientId == null || patientId.isEmpty) {
      throw CaseException('No authenticated patient to create a case for');
    }
    final response = await dio.post(
      AstraGatewayApis.companionJourneyStart,
      data: CompanionStartJourneyRequest(
        userId: patientId,
        healthConcern: 'General consultation',
      ).toJson(),
    );
    final journey = CompanionStartJourneyResponse.fromJson(response.data);
    if (journey.success != true || journey.journeyId == null) {
      throw CaseException('Failed to start a new case');
    }
    final created = Case(id: journey.journeyId!, status: CaseStatus.open);
    await SharedPreferenceHelper.setString(
        Preferences.activeCaseId, created.id);
    return created;
  }
}
