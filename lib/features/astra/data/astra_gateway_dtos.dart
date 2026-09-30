import 'package:json_annotation/json_annotation.dart';

part 'astra_gateway_dtos.g.dart';

/// `POST /api/v1/auth/session` request - exchanges a Firebase ID token for
/// an Astra-gateway JWT. See docs/backend/astra.md.
@JsonSerializable()
class AstraSessionExchangeRequest {
  @JsonKey(name: 'firebase_token')
  final String firebaseToken;

  AstraSessionExchangeRequest({required this.firebaseToken});

  factory AstraSessionExchangeRequest.fromJson(Map<String, dynamic> json) =>
      _$AstraSessionExchangeRequestFromJson(json);

  Map<String, dynamic> toJson() => _$AstraSessionExchangeRequestToJson(this);
}

@JsonSerializable()
class AstraGatewayUser {
  final String sub;
  @JsonKey(name: 'firebase_uid')
  final String firebaseUid;
  @JsonKey(name: 'user_id')
  final String userId;
  @JsonKey(name: 'patient_id')
  final String? patientId;
  final String role;

  AstraGatewayUser({
    required this.sub,
    required this.firebaseUid,
    required this.userId,
    this.patientId,
    required this.role,
  });

  factory AstraGatewayUser.fromJson(Map<String, dynamic> json) =>
      _$AstraGatewayUserFromJson(json);

  Map<String, dynamic> toJson() => _$AstraGatewayUserToJson(this);
}

/// Response shape shared by `POST /api/v1/auth/session` and
/// `POST /api/v1/auth/refresh` (both return `AuthSessionResponse` per the
/// live OpenAPI spec).
@JsonSerializable()
class AstraSessionExchangeResponse {
  @JsonKey(name: 'access_token')
  final String accessToken;
  @JsonKey(name: 'refresh_token')
  final String? refreshToken;
  @JsonKey(name: 'expires_in')
  final int expiresIn;
  final AstraGatewayUser user;

  AstraSessionExchangeResponse({
    required this.accessToken,
    this.refreshToken,
    required this.expiresIn,
    required this.user,
  });

  factory AstraSessionExchangeResponse.fromJson(Map<String, dynamic> json) =>
      _$AstraSessionExchangeResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AstraSessionExchangeResponseToJson(this);
}

/// `POST /api/companion/journey/start` request.
@JsonSerializable()
class CompanionStartJourneyRequest {
  @JsonKey(name: 'user_id')
  final String userId;
  @JsonKey(name: 'health_concern')
  final String healthConcern;
  final String language;

  CompanionStartJourneyRequest({
    required this.userId,
    required this.healthConcern,
    this.language = 'en',
  });

  factory CompanionStartJourneyRequest.fromJson(Map<String, dynamic> json) =>
      _$CompanionStartJourneyRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CompanionStartJourneyRequestToJson(this);
}

@JsonSerializable()
class CompanionStartJourneyResponse {
  final bool success;
  @JsonKey(name: 'journey_id')
  final String? journeyId;
  final String message;
  @JsonKey(name: 'welcome_message')
  final String welcomeMessage;

  CompanionStartJourneyResponse({
    required this.success,
    this.journeyId,
    required this.message,
    required this.welcomeMessage,
  });

  factory CompanionStartJourneyResponse.fromJson(Map<String, dynamic> json) =>
      _$CompanionStartJourneyResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CompanionStartJourneyResponseToJson(this);
}

/// `POST /api/companion/chat` request.
@JsonSerializable()
class CompanionChatRequest {
  @JsonKey(name: 'journey_id')
  final String journeyId;
  final String message;
  final String? language;

  CompanionChatRequest({
    required this.journeyId,
    required this.message,
    this.language,
  });

  factory CompanionChatRequest.fromJson(Map<String, dynamic> json) =>
      _$CompanionChatRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CompanionChatRequestToJson(this);
}

@JsonSerializable()
class CompanionChatResponse {
  final bool success;
  final String response;
  final String language;
  @JsonKey(name: 'detected_language')
  final String? detectedLanguage;
  @JsonKey(name: 'intervention_type')
  final String? interventionType;

  CompanionChatResponse({
    required this.success,
    required this.response,
    required this.language,
    this.detectedLanguage,
    this.interventionType,
  });

  factory CompanionChatResponse.fromJson(Map<String, dynamic> json) =>
      _$CompanionChatResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CompanionChatResponseToJson(this);
}
