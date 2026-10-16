// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'astra_fill_dtos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HealthIntake _$HealthIntakeFromJson(Map<String, dynamic> json) =>
    HealthIntake(
      primaryComplaint: json['primary_complaint'] as String,
      duration: json['duration'] as String,
      severityClues: json['severity_clues'] as String,
      patternOrTiming: json['pattern_or_timing'] as String,
      previousTreatment: json['previous_treatment'] as String,
      isFollowUp: json['is_follow_up'] as bool? ?? false,
      stopOrGapSign: json['stop_or_gap_sign'] as String?,
    );

Map<String, dynamic> _$HealthIntakeToJson(HealthIntake instance) =>
    <String, dynamic>{
      'primary_complaint': instance.primaryComplaint,
      'duration': instance.duration,
      'severity_clues': instance.severityClues,
      'pattern_or_timing': instance.patternOrTiming,
      'previous_treatment': instance.previousTreatment,
      'is_follow_up': instance.isFollowUp,
      'stop_or_gap_sign': instance.stopOrGapSign,
    };
