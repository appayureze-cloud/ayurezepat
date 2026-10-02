import 'package:json_annotation/json_annotation.dart';

import '../../../model/v2/home_response.dart' show Doctor;
import '../domain/entities/astra_card.dart';
import '../domain/entities/astra_recommendations.dart';
import '../domain/entities/astra_session.dart';
import '../domain/entities/astra_voice_result.dart';
import '../domain/entities/care_plan.dart';
import '../domain/entities/checkin_result.dart';
import '../domain/entities/medicine_info.dart';
import '../domain/entities/triage_result.dart';

part 'astra_dtos.g.dart';

@JsonSerializable()
class CreateSessionResponse {
  final bool success;
  final String? msg;
  final SessionData? data;

  CreateSessionResponse({required this.success, this.msg, this.data});

  factory CreateSessionResponse.fromJson(Map<String, dynamic> json) =>
      _$CreateSessionResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CreateSessionResponseToJson(this);
}

@JsonSerializable()
class SessionData {
  @JsonKey(name: 'session_id')
  final String sessionId;
  @JsonKey(name: 'case_id')
  final String caseId;
  final String greeting;

  SessionData({
    required this.sessionId,
    required this.caseId,
    required this.greeting,
  });

  factory SessionData.fromJson(Map<String, dynamic> json) =>
      _$SessionDataFromJson(json);

  Map<String, dynamic> toJson() => _$SessionDataToJson(this);

  AstraSession toEntity() =>
      AstraSession(sessionId: sessionId, caseId: caseId, greeting: greeting);
}

@JsonSerializable()
class TriageResponse {
  final bool success;
  final String? msg;
  final TriageData? data;

  TriageResponse({required this.success, this.msg, this.data});

  factory TriageResponse.fromJson(Map<String, dynamic> json) =>
      _$TriageResponseFromJson(json);

  Map<String, dynamic> toJson() => _$TriageResponseToJson(this);
}

@JsonSerializable()
class TriageData {
  final String route;
  final String? specialty;
  @JsonKey(name: 'red_flags')
  final List<String> redFlags;

  TriageData({required this.route, this.specialty, this.redFlags = const []});

  factory TriageData.fromJson(Map<String, dynamic> json) =>
      _$TriageDataFromJson(json);

  Map<String, dynamic> toJson() => _$TriageDataToJson(this);

  TriageResult toEntity() => TriageResult(
        route: switch (route) {
          'doctor' => TriageRoute.doctor,
          'emergency' => TriageRoute.emergency,
          _ => TriageRoute.tips,
        },
        specialty: specialty,
        redFlags: redFlags,
      );
}

/// Hand-written (not json_serializable) because `doctors` reuses the
/// existing hand-written `Doctor.fromJson` from the /doctors endpoint
/// rather than a generated one.
class RecommendationsResponse {
  final bool success;
  final String? msg;
  final AstraRecommendations data;

  RecommendationsResponse({
    required this.success,
    this.msg,
    required this.data,
  });

  factory RecommendationsResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    final tips = (data['tips'] as List<dynamic>? ?? [])
        .map((t) => TipCard(
              title: t['title'] as String? ?? '',
              body: t['body'] as String? ?? '',
            ))
        .toList();
    final doctors = (data['doctors'] as List<dynamic>? ?? [])
        .map((d) => Doctor.fromJson(d as Map<String, dynamic>))
        .toList();
    return RecommendationsResponse(
      success: json['success'] as bool? ?? false,
      msg: json['msg'] as String?,
      data: AstraRecommendations(tips: tips, doctors: doctors),
    );
  }
}

@JsonSerializable()
class VoiceResponse {
  final bool success;
  final String? msg;
  final String? transcript;
  final String? reply;
  @JsonKey(name: 'tts_url')
  final String? ttsUrl;

  VoiceResponse({
    required this.success,
    this.msg,
    this.transcript,
    this.reply,
    this.ttsUrl,
  });

  factory VoiceResponse.fromJson(Map<String, dynamic> json) =>
      _$VoiceResponseFromJson(json);

  Map<String, dynamic> toJson() => _$VoiceResponseToJson(this);

  AstraVoiceResult toEntity() => AstraVoiceResult(
        transcript: transcript ?? '',
        reply: reply ?? '',
        ttsUrl: ttsUrl,
      );
}

@JsonSerializable()
class CarePlanResponse {
  final bool success;
  final String? msg;
  final CarePlanData? data;

  CarePlanResponse({required this.success, this.msg, this.data});

  factory CarePlanResponse.fromJson(Map<String, dynamic> json) =>
      _$CarePlanResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CarePlanResponseToJson(this);
}

@JsonSerializable()
class CarePlanData {
  final List<PlannedMedicineDto> medicines;
  @JsonKey(name: 'check_ins')
  final List<String> checkIns;

  CarePlanData({this.medicines = const [], this.checkIns = const []});

  factory CarePlanData.fromJson(Map<String, dynamic> json) =>
      _$CarePlanDataFromJson(json);

  Map<String, dynamic> toJson() => _$CarePlanDataToJson(this);

  CarePlan toEntity() => CarePlan(
        medicines: medicines.map((m) => m.toEntity()).toList(),
        checkIns: checkIns,
      );
}

@JsonSerializable()
class PlannedMedicineDto {
  @JsonKey(name: 'medicine_id')
  final String medicineId;
  final String name;
  @JsonKey(name: 'dose_times')
  final List<String> doseTimes;

  PlannedMedicineDto({
    required this.medicineId,
    required this.name,
    this.doseTimes = const [],
  });

  factory PlannedMedicineDto.fromJson(Map<String, dynamic> json) =>
      _$PlannedMedicineDtoFromJson(json);

  Map<String, dynamic> toJson() => _$PlannedMedicineDtoToJson(this);

  PlannedMedicine toEntity() => PlannedMedicine(
        medicineId: medicineId,
        name: name,
        doseTimes: doseTimes,
      );
}

@JsonSerializable()
class CheckinRequest {
  @JsonKey(name: 'symptom_score')
  final int symptomScore;

  CheckinRequest({required this.symptomScore});

  factory CheckinRequest.fromJson(Map<String, dynamic> json) =>
      _$CheckinRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CheckinRequestToJson(this);
}

@JsonSerializable()
class CheckinResponse {
  final bool success;
  final String? msg;
  final CheckinData? data;

  CheckinResponse({required this.success, this.msg, this.data});

  factory CheckinResponse.fromJson(Map<String, dynamic> json) =>
      _$CheckinResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CheckinResponseToJson(this);
}

@JsonSerializable()
class CheckinData {
  @JsonKey(name: 'next_action')
  final String nextAction;
  final bool escalate;

  CheckinData({required this.nextAction, required this.escalate});

  factory CheckinData.fromJson(Map<String, dynamic> json) =>
      _$CheckinDataFromJson(json);

  Map<String, dynamic> toJson() => _$CheckinDataToJson(this);

  CheckinResult toEntity() =>
      CheckinResult(nextAction: nextAction, escalate: escalate);
}

@JsonSerializable()
class AckReminderRequest {
  final String status;

  AckReminderRequest({required this.status});

  factory AckReminderRequest.fromJson(Map<String, dynamic> json) =>
      _$AckReminderRequestFromJson(json);

  Map<String, dynamic> toJson() => _$AckReminderRequestToJson(this);
}

@JsonSerializable()
class MedicineInfoResponse {
  final bool success;
  final String? msg;
  final MedicineInfoData? data;

  MedicineInfoResponse({required this.success, this.msg, this.data});

  factory MedicineInfoResponse.fromJson(Map<String, dynamic> json) =>
      _$MedicineInfoResponseFromJson(json);

  Map<String, dynamic> toJson() => _$MedicineInfoResponseToJson(this);
}

@JsonSerializable()
class MedicineInfoData {
  @JsonKey(name: 'medicine_id')
  final String medicineId;
  final String name;
  final String description;
  @JsonKey(name: 'common_side_effects')
  final List<String> commonSideEffects;

  MedicineInfoData({
    required this.medicineId,
    required this.name,
    required this.description,
    this.commonSideEffects = const [],
  });

  factory MedicineInfoData.fromJson(Map<String, dynamic> json) =>
      _$MedicineInfoDataFromJson(json);

  Map<String, dynamic> toJson() => _$MedicineInfoDataToJson(this);

  MedicineInfo toEntity() => MedicineInfo(
        medicineId: medicineId,
        name: name,
        description: description,
        commonSideEffects: commonSideEffects,
      );
}
