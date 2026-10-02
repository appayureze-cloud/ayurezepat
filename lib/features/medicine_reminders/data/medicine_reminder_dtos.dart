import 'package:json_annotation/json_annotation.dart';

part 'medicine_reminder_dtos.g.dart';

/// `POST /api/v1/api/reminders/create` request - confirmed against the live
/// OpenAPI spec at astra.ayureze.in/openapi.json.
@JsonSerializable()
class CreateReminderRequest {
  @JsonKey(name: 'patient_id')
  final String patientId;
  @JsonKey(name: 'patient_name')
  final String? patientName;
  @JsonKey(name: 'patient_phone')
  final String? patientPhone;
  @JsonKey(name: 'medicine_name')
  final String medicineName;
  final String dosage;
  final String frequency;
  final List<String> times;
  @JsonKey(name: 'start_date')
  final String startDate;
  @JsonKey(name: 'end_date')
  final String endDate;
  final String? instructions;
  @JsonKey(name: 'enable_whatsapp')
  final bool enableWhatsapp;

  CreateReminderRequest({
    required this.patientId,
    this.patientName,
    this.patientPhone,
    required this.medicineName,
    required this.dosage,
    required this.frequency,
    required this.times,
    required this.startDate,
    required this.endDate,
    this.instructions,
    this.enableWhatsapp = true,
  });

  factory CreateReminderRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateReminderRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateReminderRequestToJson(this);
}

@JsonSerializable()
class LogAdherenceRequest {
  @JsonKey(name: 'reminder_id')
  final String reminderId;
  final bool taken;

  LogAdherenceRequest({required this.reminderId, required this.taken});

  factory LogAdherenceRequest.fromJson(Map<String, dynamic> json) =>
      _$LogAdherenceRequestFromJson(json);

  Map<String, dynamic> toJson() => _$LogAdherenceRequestToJson(this);
}

@JsonSerializable()
class SnoozeRequest {
  @JsonKey(name: 'reminder_id')
  final String reminderId;
  final int minutes;

  SnoozeRequest({required this.reminderId, this.minutes = 30});

  factory SnoozeRequest.fromJson(Map<String, dynamic> json) =>
      _$SnoozeRequestFromJson(json);

  Map<String, dynamic> toJson() => _$SnoozeRequestToJson(this);
}
