// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'astra_dtos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateSessionResponse _$CreateSessionResponseFromJson(
        Map<String, dynamic> json) =>
    CreateSessionResponse(
      success: json['success'] as bool,
      msg: json['msg'] as String?,
      data: json['data'] == null
          ? null
          : SessionData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CreateSessionResponseToJson(
        CreateSessionResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'msg': instance.msg,
      'data': instance.data,
    };

SessionData _$SessionDataFromJson(Map<String, dynamic> json) => SessionData(
      sessionId: json['session_id'] as String,
      caseId: json['case_id'] as String,
      greeting: json['greeting'] as String,
    );

Map<String, dynamic> _$SessionDataToJson(SessionData instance) =>
    <String, dynamic>{
      'session_id': instance.sessionId,
      'case_id': instance.caseId,
      'greeting': instance.greeting,
    };

TriageResponse _$TriageResponseFromJson(Map<String, dynamic> json) =>
    TriageResponse(
      success: json['success'] as bool,
      msg: json['msg'] as String?,
      data: json['data'] == null
          ? null
          : TriageData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$TriageResponseToJson(TriageResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'msg': instance.msg,
      'data': instance.data,
    };

TriageData _$TriageDataFromJson(Map<String, dynamic> json) => TriageData(
      route: json['route'] as String,
      specialty: json['specialty'] as String?,
      redFlags: (json['red_flags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$TriageDataToJson(TriageData instance) =>
    <String, dynamic>{
      'route': instance.route,
      'specialty': instance.specialty,
      'red_flags': instance.redFlags,
    };

VoiceResponse _$VoiceResponseFromJson(Map<String, dynamic> json) =>
    VoiceResponse(
      success: json['success'] as bool,
      msg: json['msg'] as String?,
      transcript: json['transcript'] as String?,
      reply: json['reply'] as String?,
      ttsUrl: json['tts_url'] as String?,
    );

Map<String, dynamic> _$VoiceResponseToJson(VoiceResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'msg': instance.msg,
      'transcript': instance.transcript,
      'reply': instance.reply,
      'tts_url': instance.ttsUrl,
    };

CarePlanResponse _$CarePlanResponseFromJson(Map<String, dynamic> json) =>
    CarePlanResponse(
      success: json['success'] as bool,
      msg: json['msg'] as String?,
      data: json['data'] == null
          ? null
          : CarePlanData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CarePlanResponseToJson(CarePlanResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'msg': instance.msg,
      'data': instance.data,
    };

CarePlanData _$CarePlanDataFromJson(Map<String, dynamic> json) => CarePlanData(
      medicines: (json['medicines'] as List<dynamic>?)
              ?.map(
                  (e) => PlannedMedicineDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      checkIns: (json['check_ins'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$CarePlanDataToJson(CarePlanData instance) =>
    <String, dynamic>{
      'medicines': instance.medicines,
      'check_ins': instance.checkIns,
    };

PlannedMedicineDto _$PlannedMedicineDtoFromJson(Map<String, dynamic> json) =>
    PlannedMedicineDto(
      medicineId: json['medicine_id'] as String,
      name: json['name'] as String,
      doseTimes: (json['dose_times'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$PlannedMedicineDtoToJson(PlannedMedicineDto instance) =>
    <String, dynamic>{
      'medicine_id': instance.medicineId,
      'name': instance.name,
      'dose_times': instance.doseTimes,
    };

CheckinRequest _$CheckinRequestFromJson(Map<String, dynamic> json) =>
    CheckinRequest(
      symptomScore: (json['symptom_score'] as num).toInt(),
    );

Map<String, dynamic> _$CheckinRequestToJson(CheckinRequest instance) =>
    <String, dynamic>{
      'symptom_score': instance.symptomScore,
    };

CheckinResponse _$CheckinResponseFromJson(Map<String, dynamic> json) =>
    CheckinResponse(
      success: json['success'] as bool,
      msg: json['msg'] as String?,
      data: json['data'] == null
          ? null
          : CheckinData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CheckinResponseToJson(CheckinResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'msg': instance.msg,
      'data': instance.data,
    };

CheckinData _$CheckinDataFromJson(Map<String, dynamic> json) => CheckinData(
      nextAction: json['next_action'] as String,
      escalate: json['escalate'] as bool,
    );

Map<String, dynamic> _$CheckinDataToJson(CheckinData instance) =>
    <String, dynamic>{
      'next_action': instance.nextAction,
      'escalate': instance.escalate,
    };

AckReminderRequest _$AckReminderRequestFromJson(Map<String, dynamic> json) =>
    AckReminderRequest(
      status: json['status'] as String,
    );

Map<String, dynamic> _$AckReminderRequestToJson(AckReminderRequest instance) =>
    <String, dynamic>{
      'status': instance.status,
    };

MedicineInfoResponse _$MedicineInfoResponseFromJson(
        Map<String, dynamic> json) =>
    MedicineInfoResponse(
      success: json['success'] as bool,
      msg: json['msg'] as String?,
      data: json['data'] == null
          ? null
          : MedicineInfoData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$MedicineInfoResponseToJson(
        MedicineInfoResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'msg': instance.msg,
      'data': instance.data,
    };

MedicineInfoData _$MedicineInfoDataFromJson(Map<String, dynamic> json) =>
    MedicineInfoData(
      medicineId: json['medicine_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      commonSideEffects: (json['common_side_effects'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$MedicineInfoDataToJson(MedicineInfoData instance) =>
    <String, dynamic>{
      'medicine_id': instance.medicineId,
      'name': instance.name,
      'description': instance.description,
      'common_side_effects': instance.commonSideEffects,
    };
