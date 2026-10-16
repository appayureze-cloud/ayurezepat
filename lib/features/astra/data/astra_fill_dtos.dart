import 'package:json_annotation/json_annotation.dart';

part 'astra_fill_dtos.g.dart';

/// `HealthIntakeSchema` - the structured fields Astra Fill extracts from a
/// patient's free-text description. Field names/requiredness confirmed
/// against the live OpenAPI spec at astra.ayureze.in/openapi.json.
@JsonSerializable()
class HealthIntake {
  @JsonKey(name: 'primary_complaint')
  final String primaryComplaint;
  final String duration;
  @JsonKey(name: 'severity_clues')
  final String severityClues;
  @JsonKey(name: 'pattern_or_timing')
  final String patternOrTiming;
  @JsonKey(name: 'previous_treatment')
  final String previousTreatment;
  @JsonKey(name: 'is_follow_up')
  final bool isFollowUp;
  @JsonKey(name: 'stop_or_gap_sign')
  final String? stopOrGapSign;

  HealthIntake({
    required this.primaryComplaint,
    required this.duration,
    required this.severityClues,
    required this.patternOrTiming,
    required this.previousTreatment,
    this.isFollowUp = false,
    this.stopOrGapSign,
  });

  factory HealthIntake.fromJson(Map<String, dynamic> json) =>
      _$HealthIntakeFromJson(json);

  Map<String, dynamic> toJson() => _$HealthIntakeToJson(this);

  HealthIntake copyWith({
    String? primaryComplaint,
    String? duration,
    String? severityClues,
    String? patternOrTiming,
    String? previousTreatment,
    bool? isFollowUp,
    String? stopOrGapSign,
  }) => HealthIntake(
        primaryComplaint: primaryComplaint ?? this.primaryComplaint,
        duration: duration ?? this.duration,
        severityClues: severityClues ?? this.severityClues,
        patternOrTiming: patternOrTiming ?? this.patternOrTiming,
        previousTreatment: previousTreatment ?? this.previousTreatment,
        isFollowUp: isFollowUp ?? this.isFollowUp,
        stopOrGapSign: stopOrGapSign ?? this.stopOrGapSign,
      );
}

/// `POST /api/v1/astra-fill/process-text` response - confirmed live
/// (astra.ayureze.in returns this exact shape, not the generic
/// `additionalProperties: true` the spec declares).
class AstraFillExtraction {
  final String extractionId;
  final HealthIntake data;
  final String rawTranscript;

  AstraFillExtraction({
    required this.extractionId,
    required this.data,
    required this.rawTranscript,
  });

  factory AstraFillExtraction.fromJson(Map<String, dynamic> json) {
    final inner = json['data'] as Map<String, dynamic>;
    return AstraFillExtraction(
      extractionId: json['extraction_id'] as String,
      data: HealthIntake.fromJson(
          inner['structured_data'] as Map<String, dynamic>),
      rawTranscript: inner['raw_transcript'] as String? ?? '',
    );
  }
}
