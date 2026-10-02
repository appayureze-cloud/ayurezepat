// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'whatsapp_consent_dtos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AutopilotConsentRequest _$AutopilotConsentRequestFromJson(
        Map<String, dynamic> json) =>
    AutopilotConsentRequest(
      patientId: json['patient_id'] as String,
      consentGranted: json['consent_granted'] as bool,
    );

Map<String, dynamic> _$AutopilotConsentRequestToJson(
        AutopilotConsentRequest instance) =>
    <String, dynamic>{
      'patient_id': instance.patientId,
      'consent_granted': instance.consentGranted,
    };

AutopilotStatusResponse _$AutopilotStatusResponseFromJson(
        Map<String, dynamic> json) =>
    AutopilotStatusResponse(
      patientId: json['patient_id'] as String,
      isEnabled: json['is_enabled'] as bool,
      careJourneyStage: json['care_journey_stage'] as String?,
      lastCheck: json['last_check'] as String?,
      pendingAction: json['pending_action'] as String?,
    );

Map<String, dynamic> _$AutopilotStatusResponseToJson(
        AutopilotStatusResponse instance) =>
    <String, dynamic>{
      'patient_id': instance.patientId,
      'is_enabled': instance.isEnabled,
      'care_journey_stage': instance.careJourneyStage,
      'last_check': instance.lastCheck,
      'pending_action': instance.pendingAction,
    };
