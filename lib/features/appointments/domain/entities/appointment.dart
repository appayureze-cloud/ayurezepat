/// A booked consultation - the `consultations` table row, as returned by
/// app/appointment_routes.py (and read elsewhere by app/finance_routes.py
/// for payment). `status` starts 'booked_unpaid' on creation; payment moves
/// it forward via the normal finance flow. `payment_status` is the separate
/// Razorpay-tracked field ('pending'/'paid'/'failed'/'refunded').
class Appointment {
  final String consultationId;
  final String doctorId;
  final String doctorName;
  final DateTime appointmentDate;
  final String consultationType;
  final String status;
  final String paymentStatus;
  final int? totalFee;

  const Appointment({
    required this.consultationId,
    required this.doctorId,
    required this.doctorName,
    required this.appointmentDate,
    required this.consultationType,
    required this.status,
    required this.paymentStatus,
    this.totalFee,
  });

  bool get isCancelled => status == 'cancelled';
  bool get isPaid => paymentStatus == 'paid';

  factory Appointment.fromJson(Map<String, dynamic> json) => Appointment(
        consultationId: json['consultation_id']?.toString() ?? '',
        doctorId: json['doctor_id']?.toString() ?? '',
        doctorName: json['doctor_name'] as String? ?? 'Doctor',
        appointmentDate:
            DateTime.tryParse(json['appointment_date'] as String? ?? '') ??
                DateTime.now(),
        consultationType: json['consultation_type'] as String? ?? 'video',
        status: json['status'] as String? ?? 'booked_unpaid',
        paymentStatus: json['payment_status'] as String? ?? 'pending',
        totalFee: (json['total_fee'] as num?)?.toInt(),
      );
}
