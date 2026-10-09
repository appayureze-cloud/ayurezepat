import 'entities/appointment.dart';
import 'entities/doctor_summary.dart';

class AppointmentException implements Exception {
  final String message;
  AppointmentException(this.message);

  @override
  String toString() => message;
}

abstract class AppointmentRepository {
  Future<List<DoctorSummary>> listDoctors({String? specialization});

  /// Returns open slot times (e.g. "09:30") for a doctor on [date]
  /// (YYYY-MM-DD).
  Future<List<String>> getSlots(String doctorId, String date);

  /// Books an unpaid consultation for the given doctor/date/time. Returns
  /// the new consultation_id - pay for it next via createPaymentOrder/
  /// verifyPayment.
  Future<String> book({
    required String doctorId,
    required String date,
    required String time,
    String consultationType = 'video',
  });

  Future<List<Appointment>> myAppointments();

  Future<void> cancel(String consultationId);

  /// Creates a server-priced Razorpay order for an already-booked
  /// consultation.
  Future<PaymentOrderRef> createPaymentOrder({
    required String consultationId,
    required String doctorId,
    required int amountRupees,
  });

  /// Verifies the Razorpay callback server-side and marks the consultation
  /// paid.
  Future<bool> verifyPayment({
    required String consultationId,
    required String razorpayPaymentId,
    required String razorpayOrderId,
    required String razorpaySignature,
  });
}

class PaymentOrderRef {
  final String orderId;
  final String keyId;
  final int amount;
  final String currency;

  const PaymentOrderRef({
    required this.orderId,
    required this.keyId,
    required this.amount,
    required this.currency,
  });
}
