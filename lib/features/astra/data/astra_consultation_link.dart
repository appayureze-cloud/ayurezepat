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
/// Deliberately starts a fresh journey/case per booking rather than reusing
/// an existing one: each appointment is its own consultation (potentially a
/// different doctor or concern each time), matching how the Astra chat tab
/// already starts its own journey per session.
///
/// `appointmentId` and `laravelDio` are optional only so existing call sites
/// that predate this still compile; pass both to actually stitch the case
/// back onto the appointment (see below) - without `appointmentId` the
/// doctor app has no way to ever discover a case created here (there is no
/// "list cases by doctor_id" endpoint on the Astra side; see
/// docs/backend/astra_doctor_patient_flow.md).
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
