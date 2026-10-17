/// A single day's wellness log: the local, on-device equivalent of a
/// "routine tracker" + "symptom diary". There's no backend endpoint for
/// this (Astra only has the single daily check-in symptom score via
/// `astra/cases/{id}/checkins`), so this is purely client-side state - one
/// entry per calendar day, upserted by [dateKey] rather than accumulating
/// duplicates when a patient edits today's entry more than once.
class WellnessEntry {
  final String dateKey; // yyyy-MM-dd, also the upsert key
  final double? sleepHours;
  final int? movementMinutes;
  final int? relaxationMinutes;
  final int? mood; // 1 (low) - 5 (great)
  final String? note;
  final String updatedAt; // ISO8601, for "last edited" display only

  const WellnessEntry({
    required this.dateKey,
    this.sleepHours,
    this.movementMinutes,
    this.relaxationMinutes,
    this.mood,
    this.note,
    required this.updatedAt,
  });

  WellnessEntry copyWith({
    double? sleepHours,
    int? movementMinutes,
    int? relaxationMinutes,
    int? mood,
    String? note,
  }) =>
      WellnessEntry(
        dateKey: dateKey,
        sleepHours: sleepHours ?? this.sleepHours,
        movementMinutes: movementMinutes ?? this.movementMinutes,
        relaxationMinutes: relaxationMinutes ?? this.relaxationMinutes,
        mood: mood ?? this.mood,
        note: note ?? this.note,
        updatedAt: DateTime.now().toIso8601String(),
      );

  Map<String, dynamic> toJson() => {
        'date_key': dateKey,
        'sleep_hours': sleepHours,
        'movement_minutes': movementMinutes,
        'relaxation_minutes': relaxationMinutes,
        'mood': mood,
        'note': note,
        'updated_at': updatedAt,
      };

  factory WellnessEntry.fromJson(Map<String, dynamic> json) => WellnessEntry(
        dateKey: json['date_key'] as String,
        sleepHours: (json['sleep_hours'] as num?)?.toDouble(),
        movementMinutes: json['movement_minutes'] as int?,
        relaxationMinutes: json['relaxation_minutes'] as int?,
        mood: json['mood'] as int?,
        note: json['note'] as String?,
        updatedAt:
            json['updated_at'] as String? ?? DateTime.now().toIso8601String(),
      );

  static String dateKeyFor(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}
