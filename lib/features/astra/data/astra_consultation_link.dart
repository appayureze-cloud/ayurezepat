import 'package:collection/collection.dart';
import 'package:dio/dio.dart';

import '../../../api/network_api.dart';
import '../../../v2/utils/logger.dart';
import 'astra_gateway_apis.dart';
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
/// Reuses the patient's existing active journey (`GET /api/companion/
/// journey/user/{user_id}`) when one exists, rather than always starting a
/// fresh one - avoids the duplicate-journey-per-booking problem a patient
/// booking multiple appointments for the same ongoing concern would
/// otherwise hit. A new journey is only started when none is active.
///

/// `appointmentId` and `laravelDio` are optional only so existing call sites
/// that predate this still compile; pass both to actually stitch the case
/// back onto the appointment (see below). `GET /api/companion/case/by-doctor/
/// {doctor_id}` does exist and is doctor-role-gated (confirmed live), so the
/// doctor app can discover cases this way even without the Laravel stitch
/// below - but it still can't tell which case belongs to which appointment
/// without it.
Future<void> linkAppointmentToAstra({
  required int doctorId,
  required String healthConcern,
  String? appointmentId,
  Dio? laravelDio,
}) async {
  final gateway = AstraGatewayClient();
  // Must come first: this is what actually performs the Firebase->Astra
  // session exchange and populates cachedUserId below. A patient who hasn't
  // opened the Astra chat tab yet has no cached id until this runs - reading
  // cachedUserId before this call would always bail out for them.
  final dio = await gateway.dio();

  final patientId = gateway.cachedUserId;
  if (patientId == null || patientId.isEmpty) return;

  String? journeyId;
  try {
    final existing =
        await dio.get(AstraGatewayApis.companionJourneyUser(patientId));
    final journeys =
        (existing.data as Map<String, dynamic>)['journeys'] as List<dynamic>?;
    final active = journeys
        ?.cast<Map<String, dynamic>>()
        .where((j) => j['status'] == 'active')
        .firstOrNull;
    journeyId = active?['journey_id'] as String? ?? active?['id'] as String?;
  } catch (e) {
    logger.w('Failed to check for an existing journey before booking: $e');
  }

  if (journeyId == null) {
    final journeyResponse = await dio.post(
      AstraGatewayApis.companionJourneyStart,
      data: CompanionStartJourneyRequest(
        userId: patientId,
        healthConcern:
            healthConcern.isNotEmpty ? healthConcern : 'Consultation',
      ).toJson(),
    );
    final journey =
        CompanionStartJourneyResponse.fromJson(journeyResponse.data);
    if (journey.success != true || journey.journeyId == null) {
      logger.w('Astra journey/start did not return a journey_id for booking');
      return;
    }
    journeyId = journey.journeyId!;
  }

  final caseResponse = await dio.post(
    AstraGatewayApis.companionCaseCreate,
    data: CompanionCreateCaseRequest(
      journeyId: journeyId,
      userId: patientId,
      doctorId: 'DOC-$doctorId',
      diagnosis:
          healthConcern.isNotEmpty ? healthConcern : 'Pending consultation',
    ).toJson(),
  );
  final result = CompanionCreateCaseResponse.fromJson(caseResponse.data);
  if (result.success != true) {
    logger.w('Astra case/create returned failure: ${result.message}');
    return;
  }

  final caseId = result.caseId;
  if (caseId == null || appointmentId == null || laravelDio == null) return;

  // Best-effort, same as everything above: a failure here must not surface
  // to the user, since the booking itself already succeeded. This route
  // does not exist on the Laravel backend yet (confirmed: not in any
  // accessible backend source), so this currently always fails and logs -
  // once Laravel accepts POST link_appointment_astra_case with
  // {appointment_id, astra_case_id} and persists astra_case_id onto that
  // appointment row (surfaced back on GET get_appointment/{id} as
  // astra_case_id - see Appointment.astraCaseId in
  // model/v2/appointment_details_response.dart), this starts working with
  // no further client change.
  try {
    await RestClient(laravelDio).linkAppointmentAstraCase({
      'appointment_id': appointmentId,
      'astra_case_id': caseId,
    });
  } catch (e) {
    logger.w('Failed to stitch astra_case_id onto Laravel appointment '
        '$appointmentId (expected until that backend route exists): $e');
  }
}
