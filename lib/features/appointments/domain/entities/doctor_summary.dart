/// A doctor as shown in the booking flow's browse list - sourced from
/// GET /api/v1/appointments/doctors (app/appointment_routes.py), which
/// reads the real Supabase `doctors` table, the same source the Admin CRM
/// uses - not GET /api/doctors/nearby/search, which requires GPS
/// coordinates and has fragile fallback handling.
class DoctorSummary {
  final String doctorId;
  final String name;
  final String? specialization;
  final bool isVerified;
  final String? photoUrl;

  const DoctorSummary({
    required this.doctorId,
    required this.name,
    this.specialization,
    this.isVerified = false,
    this.photoUrl,
  });

  factory DoctorSummary.fromJson(Map<String, dynamic> json) => DoctorSummary(
        doctorId: json['doctor_id']?.toString() ?? '',
        name: json['name'] as String? ?? 'Doctor',
        specialization: json['specialization'] as String?,
        isVerified: json['is_face_verified'] as bool? ?? false,
        photoUrl: json['photo_url'] as String?,
      );
}
