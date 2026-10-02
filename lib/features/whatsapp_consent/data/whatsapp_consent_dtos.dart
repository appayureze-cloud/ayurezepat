import 'package:json_annotation/json_annotation.dart';

import '../domain/entities/whatsapp_consent.dart';

part 'whatsapp_consent_dtos.g.dart';

/// `POST /api/v1/autopilot/consent` request - confirmed against the real
/// Astra gateway (astra.ayureze.in) during a Phase 4 connectivity audit.
/// See docs/backend/astra.md.
@JsonSerializable()
class AutopilotConsentRequest {
  @JsonKey(name: 'patient_id')
  final String patientId;
  @JsonKey(name: 'consent_granted')
  final bool consentGranted;

  AutopilotConsentRequest({
    required this.patientId,
    required this.consentGranted,
  });

  factory AutopilotConsentRequest.fromJson(Map<String, dynamic> json) =>
      _$AutopilotConsentRequestFromJson(json);

  Map<String, dynamic> toJson() => _$AutopilotConsentRequestToJson(this);
}

/// `GET /api/v1/autopilot/status/{patient_id}` response - this exact shape
/// was observed live against astra.ayureze.in during the audit (not a
/// guess, unlike most of the gateway's other response schemas, which
/// aren't fixed in the published OpenAPI spec).
@JsonSerializable()
class AutopilotStatusResponse {
  @JsonKey(name: 'patient_id')
  final String patientId;
  @JsonKey(name: 'is_enabled')
  final bool isEnabled;
  @JsonKey(name: 'care_journey_stage')
  final String? careJourneyStage;
  @JsonKey(name: 'last_check')
  final String? lastCheck;
  @JsonKey(name: 'pending_action')
  final String? pendingAction;

  AutopilotStatusResponse({
    required this.patientId,
    required this.isEnabled,
    this.careJourneyStage,
    this.lastCheck,
    this.pendingAction,
  });

  factory AutopilotStatusResponse.fromJson(Map<String, dynamic> json) =>
      _$AutopilotStatusResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AutopilotStatusResponseToJson(this);

  WhatsappConsent toEntity() =>
      WhatsappConsent(optedIn: isEnabled, consentedAt: lastCheck);
}
