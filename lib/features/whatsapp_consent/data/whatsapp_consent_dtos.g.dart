// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'whatsapp_consent_dtos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WhatsappConsentRequest _$WhatsappConsentRequestFromJson(
        Map<String, dynamic> json) =>
    WhatsappConsentRequest(
      optedIn: json['opted_in'] as bool,
      phone: json['phone'] as String,
      caseId: json['case_id'] as String?,
    );

Map<String, dynamic> _$WhatsappConsentRequestToJson(
        WhatsappConsentRequest instance) =>
    <String, dynamic>{
      'opted_in': instance.optedIn,
      'phone': instance.phone,
      'case_id': instance.caseId,
    };

WhatsappConsentResponse _$WhatsappConsentResponseFromJson(
        Map<String, dynamic> json) =>
    WhatsappConsentResponse(
      success: json['success'] as bool,
      msg: json['msg'] as String?,
      data: json['data'] == null
          ? null
          : WhatsappConsentData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$WhatsappConsentResponseToJson(
        WhatsappConsentResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'msg': instance.msg,
      'data': instance.data,
    };

WhatsappConsentData _$WhatsappConsentDataFromJson(Map<String, dynamic> json) =>
    WhatsappConsentData(
      optedIn: json['opted_in'] as bool,
      consentedAt: json['consented_at'] as String?,
    );

Map<String, dynamic> _$WhatsappConsentDataToJson(
        WhatsappConsentData instance) =>
    <String, dynamic>{
      'opted_in': instance.optedIn,
      'consented_at': instance.consentedAt,
    };
