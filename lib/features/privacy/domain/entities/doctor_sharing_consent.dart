/// A patient's stated preference on whether a specific doctor they've
/// consulted may see their fuller health record (beyond what that
/// consultation itself already sent). This is a LOCAL record of intent
/// only - there is no backend endpoint that currently reads or enforces
/// per-doctor data-sharing scopes, so toggling this does not yet change
/// what any doctor can actually see. It exists so the preference is
/// captured and ready to wire up once such an endpoint exists, and so the
/// patient has somewhere to express it rather than nowhere at all.
class DoctorSharingConsent {
  final String doctorId;
  final String doctorName;
  final bool shareFullRecord;
  final String updatedAt; // ISO8601

  const DoctorSharingConsent({
    required this.doctorId,
    required this.doctorName,
    required this.shareFullRecord,
    required this.updatedAt,
  });

  DoctorSharingConsent copyWith({bool? shareFullRecord}) =>
      DoctorSharingConsent(
        doctorId: doctorId,
        doctorName: doctorName,
        shareFullRecord: shareFullRecord ?? this.shareFullRecord,
        updatedAt: DateTime.now().toIso8601String(),
      );

  Map<String, dynamic> toJson() => {
        'doctor_id': doctorId,
        'doctor_name': doctorName,
        'share_full_record': shareFullRecord,
        'updated_at': updatedAt,
      };

  factory DoctorSharingConsent.fromJson(Map<String, dynamic> json) =>
      DoctorSharingConsent(
        doctorId: json['doctor_id'] as String,
        doctorName: json['doctor_name'] as String? ?? 'Doctor',
        shareFullRecord: json['share_full_record'] as bool? ?? false,
        updatedAt:
            json['updated_at'] as String? ?? DateTime.now().toIso8601String(),
      );
}
