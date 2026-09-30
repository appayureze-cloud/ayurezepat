// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'astra_gateway_dtos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AstraSessionExchangeRequest _$AstraSessionExchangeRequestFromJson(
        Map<String, dynamic> json) =>
    AstraSessionExchangeRequest(
      firebaseToken: json['firebase_token'] as String,
    );

Map<String, dynamic> _$AstraSessionExchangeRequestToJson(
        AstraSessionExchangeRequest instance) =>
    <String, dynamic>{
      'firebase_token': instance.firebaseToken,
    };

AstraGatewayUser _$AstraGatewayUserFromJson(Map<String, dynamic> json) =>
    AstraGatewayUser(
      sub: json['sub'] as String,
      firebaseUid: json['firebase_uid'] as String,
      userId: json['user_id'] as String,
      patientId: json['patient_id'] as String?,
      role: json['role'] as String,
    );

Map<String, dynamic> _$AstraGatewayUserToJson(AstraGatewayUser instance) =>
    <String, dynamic>{
      'sub': instance.sub,
      'firebase_uid': instance.firebaseUid,
      'user_id': instance.userId,
      'patient_id': instance.patientId,
      'role': instance.role,
    };

AstraSessionExchangeResponse _$AstraSessionExchangeResponseFromJson(
        Map<String, dynamic> json) =>
    AstraSessionExchangeResponse(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String?,
      expiresIn: (json['expires_in'] as num).toInt(),
      user: AstraGatewayUser.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AstraSessionExchangeResponseToJson(
        AstraSessionExchangeResponse instance) =>
    <String, dynamic>{
      'access_token': instance.accessToken,
      'refresh_token': instance.refreshToken,
      'expires_in': instance.expiresIn,
      'user': instance.user,
    };

CompanionStartJourneyRequest _$CompanionStartJourneyRequestFromJson(
        Map<String, dynamic> json) =>
    CompanionStartJourneyRequest(
      userId: json['user_id'] as String,
      healthConcern: json['health_concern'] as String,
      language: json['language'] as String? ?? 'en',
    );

Map<String, dynamic> _$CompanionStartJourneyRequestToJson(
        CompanionStartJourneyRequest instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'health_concern': instance.healthConcern,
      'language': instance.language,
    };

CompanionStartJourneyResponse _$CompanionStartJourneyResponseFromJson(
        Map<String, dynamic> json) =>
    CompanionStartJourneyResponse(
      success: json['success'] as bool,
      journeyId: json['journey_id'] as String?,
      message: json['message'] as String,
      welcomeMessage: json['welcome_message'] as String,
    );

Map<String, dynamic> _$CompanionStartJourneyResponseToJson(
        CompanionStartJourneyResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'journey_id': instance.journeyId,
      'message': instance.message,
      'welcome_message': instance.welcomeMessage,
    };

CompanionChatRequest _$CompanionChatRequestFromJson(
        Map<String, dynamic> json) =>
    CompanionChatRequest(
      journeyId: json['journey_id'] as String,
      message: json['message'] as String,
      language: json['language'] as String?,
    );

Map<String, dynamic> _$CompanionChatRequestToJson(
        CompanionChatRequest instance) =>
    <String, dynamic>{
      'journey_id': instance.journeyId,
      'message': instance.message,
      'language': instance.language,
    };

CompanionChatResponse _$CompanionChatResponseFromJson(
        Map<String, dynamic> json) =>
    CompanionChatResponse(
      success: json['success'] as bool,
      response: json['response'] as String,
      language: json['language'] as String,
      detectedLanguage: json['detected_language'] as String?,
      interventionType: json['intervention_type'] as String?,
    );

Map<String, dynamic> _$CompanionChatResponseToJson(
        CompanionChatResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'response': instance.response,
      'language': instance.language,
      'detected_language': instance.detectedLanguage,
      'intervention_type': instance.interventionType,
    };
