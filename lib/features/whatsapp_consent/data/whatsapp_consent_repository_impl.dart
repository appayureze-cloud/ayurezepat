import 'package:dio/dio.dart';

import '../../../const/prefConstatnt.dart';
import '../../../const/preference.dart';
import '../../astra/data/astra_gateway_apis.dart';
import '../../astra/data/astra_gateway_auth.dart';
import '../../astra/data/astra_gateway_client.dart';
import '../domain/entities/whatsapp_consent.dart';
import '../domain/whatsapp_consent_repository.dart';
import 'whatsapp_consent_dtos.dart';

class WhatsappConsentException implements Exception {
  final String message;
  WhatsappConsentException(this.message);

  @override
  String toString() => message;
}

/// Talks to the real Astra gateway's "autopilot" (proactive AI follow-up)
/// consent API, confirmed live during a Phase 4 connectivity audit - see
/// docs/backend/astra.md. This replaces the originally speculative
/// `/consents/whatsapp` contract from Phase 3, which was never confirmed
/// against a real backend. `dio` is kept for constructor-shape
/// compatibility with `WhatsappConsentService.withDio` but unused - like
/// the other gateway-backed repositories, this builds its own
/// [AstraGatewayClient] internally, since the gateway is a different host
/// with its own auth.
class WhatsappConsentRepositoryImpl implements WhatsappConsentRepository {
  final Dio dio;
  final AstraGatewayClient _gateway;

  WhatsappConsentRepositoryImpl(this.dio, [AstraGatewayClient? gateway])
      : _gateway = gateway ?? AstraGatewayClient();

  @override
  Future<WhatsappConsent> getConsent() async {
    final patientId = _requirePatientId();
    final gatewayDio = await _gateway.dio();
    final response =
        await gatewayDio.get(AstraGatewayApis.autopilotStatus(patientId));
    final consent = AutopilotStatusResponse.fromJson(response.data).toEntity();
    await _cacheLocally(consent);
    return consent;
  }

  @override
  Future<WhatsappConsent> setConsent({
    required bool optedIn,
    // Unused here: the confirmed `/api/v1/autopilot/consent` request body
    // only takes `patient_id` and `consent_granted`. Kept on the method
    // signature to satisfy [WhatsappConsentRepository] (shared with
    // [MockWhatsappConsentRepository], which does use it) - the call site
    // still gates the toggle on the patient having a phone number on file,
    // which is a real product requirement independent of this one request.
    required String phone,
  }) async {
    final patientId = _requirePatientId();
    final gatewayDio = await _gateway.dio();
    await gatewayDio.post(
      AstraGatewayApis.autopilotConsent,
      data: AutopilotConsentRequest(
        patientId: patientId,
        consentGranted: optedIn,
      ).toJson(),
    );
    // The consent endpoint's response has no fixed schema, so re-fetch
    // status (confirmed shape) rather than guess at what it returned.
    return getConsent();
  }

  String _requirePatientId() {
    final patientId = AstraGatewayAuth().cachedUserId;
    if (patientId == null || patientId.isEmpty) {
      throw WhatsappConsentException(
          'No Astra patient id yet - open Astra chat first.');
    }
    return patientId;
  }

  Future<void> _cacheLocally(WhatsappConsent consent) async {
    await SharedPreferenceHelper.setBoolean(
        Preferences.whatsappConsentOptedIn, consent.optedIn);
    if (consent.consentedAt != null) {
      await SharedPreferenceHelper.setString(
          Preferences.whatsappConsentAt, consent.consentedAt!);
    }
  }
}
