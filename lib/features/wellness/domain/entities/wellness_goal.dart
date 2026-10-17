/// A simple, patient-set wellness goal (e.g. "Sleep 7+ hours", "Walk daily").
/// Purely local and purely declarative - there's no backend tracking of
/// progress against it; [progressNote] is the patient's own free-text
/// update, not a computed value.
class WellnessGoal {
  final String id;
  final String title;
  final bool achieved;
  final String createdAt; // ISO8601

  const WellnessGoal({
    required this.id,
    required this.title,
    this.achieved = false,
    required this.createdAt,
  });

  WellnessGoal copyWith({String? title, bool? achieved}) => WellnessGoal(
        id: id,
        title: title ?? this.title,
        achieved: achieved ?? this.achieved,
        createdAt: createdAt,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'achieved': achieved,
        'created_at': createdAt,
      };

  factory WellnessGoal.fromJson(Map<String, dynamic> json) => WellnessGoal(
        id: json['id'] as String,
        title: json['title'] as String,
        achieved: json['achieved'] as bool? ?? false,
        createdAt:
            json['created_at'] as String? ?? DateTime.now().toIso8601String(),
      );
}
