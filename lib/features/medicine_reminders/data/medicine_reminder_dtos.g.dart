// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medicine_reminder_dtos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateReminderRequest _$CreateReminderRequestFromJson(
        Map<String, dynamic> json) =>
    CreateReminderRequest(
      patientId: json['patient_id'] as String,
      patientName: json['patient_name'] as String?,
      patientPhone: json['patient_phone'] as String?,
      medicineName: json['medicine_name'] as String,
      dosage: json['dosage'] as String,
      frequency: json['frequency'] as String,
      times: (json['times'] as List<dynamic>).map((e) => e as String).toList(),
      startDate: json['start_date'] as String,
      endDate: json['end_date'] as String,
      instructions: json['instructions'] as String?,
      enableWhatsapp: json['enable_whatsapp'] as bool? ?? true,
    );

Map<String, dynamic> _$CreateReminderRequestToJson(
        CreateReminderRequest instance) =>
    <String, dynamic>{
      'patient_id': instance.patientId,
      'patient_name': instance.patientName,
      'patient_phone': instance.patientPhone,
      'medicine_name': instance.medicineName,
      'dosage': instance.dosage,
      'frequency': instance.frequency,
      'times': instance.times,
      'start_date': instance.startDate,
      'end_date': instance.endDate,
      'instructions': instance.instructions,
      'enable_whatsapp': instance.enableWhatsapp,
    };

LogAdherenceRequest _$LogAdherenceRequestFromJson(Map<String, dynamic> json) =>
    LogAdherenceRequest(
      reminderId: json['reminder_id'] as String,
      taken: json['taken'] as bool,
    );

Map<String, dynamic> _$LogAdherenceRequestToJson(
        LogAdherenceRequest instance) =>
    <String, dynamic>{
      'reminder_id': instance.reminderId,
      'taken': instance.taken,
    };

SnoozeRequest _$SnoozeRequestFromJson(Map<String, dynamic> json) =>
    SnoozeRequest(
      reminderId: json['reminder_id'] as String,
      minutes: (json['minutes'] as num?)?.toInt() ?? 30,
    );

Map<String, dynamic> _$SnoozeRequestToJson(SnoozeRequest instance) =>
    <String, dynamic>{
      'reminder_id': instance.reminderId,
      'minutes': instance.minutes,
    };
