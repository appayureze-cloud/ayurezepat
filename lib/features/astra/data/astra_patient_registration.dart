import '../../../v2/utils/logger.dart';
import 'astra_gateway_apis.dart';
import 'astra_gateway_client.dart';

/// Ensures a Supabase `patient_profiles` row exists for the patient who
/// just logged in or signed up, by calling Astra's own
/// `POST /api/v1/patients/register` directly - rather than relying on
/// `sync_service.py`'s hourly MySQL-to-Supabase sync to eventually create
/// it. Best-effort and non-blocking, same pattern as
/// [linkAppointmentToAstra]: a login/signup must never fail or wait on
/// this, and the endpoint is expected to already return success (not an
/// error) for a patient the hourly sync already created.
///
/// Requires a Firebase session to already exist - call this only after
/// Firebase sign-in/sign-up succeeds, since `AstraGatewayClient.dio()`
/// performs the Firebase-to-Astra token exchange this endpoint needs.
Future<void> registerPatientWithAstra({
  required String name,
  String? email,
  String? phone,
}) async {
  try {
    final dio = await AstraGatewayClient().dio();
    await dio.post(
      AstraGatewayApis.patientsRegister,
      data: {
        'name': name,
        if (email != null && email.isNotEmpty) 'email': email,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
      },
    );
  } catch (e) {
    logger.w('Astra patients/register failed (non-fatal, relies on the '
        'hourly MySQL->Supabase sync as a fallback): $e');
  }
}
