import 'package:json_annotation/json_annotation.dart';

import '../domain/entities/whatsapp_consent.dart';

part 'whatsapp_consent_dtos.g.dart';

@JsonSerializable()
class WhatsappConsentRequest {
  @JsonKey(name: 'opted_in')
  final bool optedIn;
  final String phone;
  @JsonKey(name: 'case_id')
  final String? caseId;

  WhatsappConsentRequest({
    required this.optedIn,
    required this.phone,
    this.caseId,
  });

  factory WhatsappConsentRequest.fromJson(Map<String, dynamic> json) =>
      _$WhatsappConsentRequestFromJson(json);

  Map<String, dynamic> toJson() => _$WhatsappConsentRequestToJson(this);
}

@JsonSerializable()
class WhatsappConsentResponse {
  final bool success;
  final String? msg;
  final WhatsappConsentData? data;

  WhatsappConsentResponse({required this.success, this.msg, this.data});

  factory WhatsappConsentResponse.fromJson(Map<String, dynamic> json) =>
      _$WhatsappConsentResponseFromJson(json);

  Map<String, dynamic> toJson() => _$WhatsappConsentResponseToJson(this);
}

@JsonSerializable()
class WhatsappConsentData {
  @JsonKey(name: 'opted_in')
  final bool optedIn;
  @JsonKey(name: 'consented_at')
  final String? consentedAt;

  WhatsappConsentData({required this.optedIn, this.consentedAt});

  factory WhatsappConsentData.fromJson(Map<String, dynamic> json) =>
      _$WhatsappConsentDataFromJson(json);

  Map<String, dynamic> toJson() => _$WhatsappConsentDataToJson(this);

  WhatsappConsent toEntity() =>
      WhatsappConsent(optedIn: optedIn, consentedAt: consentedAt);
}
