import '../../../model/v2/home_response.dart' show Doctor;
import '../domain/entities/astra_card.dart';

/// Parses one card from the `cards[]` array documented in the Astra
/// contract (`POST /astra/sessions/{id}/messages`), keyed by `kind`.
AstraCard? parseAstraCard(Map<String, dynamic> json) {
  final kind = json['kind'] as String?;
  switch (kind) {
    case 'tip':
      return TipCard(
        title: json['title'] as String? ?? '',
        body: json['body'] as String? ?? '',
      );
    case 'doctor':
      final doctorJson = json['doctor'] as Map<String, dynamic>?;
      if (doctorJson == null) return null;
      return DoctorRecommendationCard(
        doctor: Doctor.fromJson(doctorJson),
        reason: json['reason'] as String?,
      );
    case 'order':
      return OrderCard(
        orderId: json['order_id'] as String? ?? '',
        summary: json['summary'] as String? ?? '',
      );
    case 'reminder':
      return ReminderCard(
        reminderId: json['reminder_id'] as String? ?? '',
        medicineName: json['medicine_name'] as String? ?? '',
        time: json['time'] as String? ?? '',
      );
    case 'emergency':
      return EmergencyCard(
        message: json['message'] as String? ??
            'This may be a medical emergency. Please call 112 or go to the nearest emergency room now.',
        redFlags: (json['red_flags'] as List<dynamic>? ?? [])
            .map((e) => e.toString())
            .toList(),
      );
    default:
      return null;
  }
}
