import '../../../v2/utils/logger.dart';
import 'astra_gateway_apis.dart';
import 'astra_gateway_auth.dart';
import 'astra_gateway_client.dart';
import 'astra_gateway_dtos.dart';

/// Links a freshly-booked Laravel appointment to an Astra companion case, so
/// the AI companion and video-call channel naming (both already keyed by
/// doctor_id/patient_id, see docs/backend/astra_doctor_patient_flow.md) are
/// tied to a real, already-booked consultation instead of requiring any
/// manual setup. Best-effort and non-blocking: a booking must never fail or
/// wait on this.
///
/// `doctorId` is Laravel's own `doctor` table id (the same id
/// `MakeAppointmentModal.doctor.id` already carries for booking) - prefixed
/// with `DOC-` to match the id format `sync_service.py` assigns when it
/// syncs that same row into Astra's Supabase `doctors` table.
///
/// Deliberately starts a fresh journey/case per booking rather than reusing
/// an existing one: each appointment is its own consultation (potentially a
/// different doctor or concern each time), matching how the Astra chat tab
/// already starts its own journey per session.
Future<void> linkAppointmentToAstra({
  required int doctorId,
  required String healthConcern,
}) async {
  final patientId = AstraGatewayAuth().cachedUserId;
  if (patientId == null || patientId.isEmpty) return;

  final gateway = AstraGatewayClient();
  final dio = await gateway.dio();

  final journeyResponse = await dio.post(
    AstraGatewayApis.companionJourneyStart,
    data: CompanionStartJourneyRequest(
      userId: patientId,
      healthConcern: healthConcern.isNotEmpty ? healthConcern : 'Consultation',
    ).toJson(),
  );
  final journey = CompanionStartJourneyResponse.fromJson(journeyResponse.data);
  if (journey.success != true || journey.journeyId == null) {
    logger.w('Astra journey/start did not return a journey_id for booking');
    return;
  }

  final caseResponse = await dio.post(
    AstraGatewayApis.companionCaseCreate,
    data: CompanionCreateCaseRequest(
      journeyId: journey.journeyId!,
      userId: patientId,
      doctorId: 'DOC-$doctorId',
      diagnosis:
          healthConcern.isNotEmpty ? healthConcern : 'Pending consultation',
    ).toJson(),
  );
  final result = CompanionCreateCaseResponse.fromJson(caseResponse.data);
  if (result.success != true) {
    logger.w('Astra case/create returned failure: ${result.message}');
  }
}
