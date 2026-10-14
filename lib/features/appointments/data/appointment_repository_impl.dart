import '../../astra/data/astra_gateway_apis.dart';
import '../../astra/data/astra_gateway_client.dart';
import '../domain/appointment_repository.dart';
import '../domain/entities/appointment.dart';
import '../domain/entities/doctor_summary.dart';

/// Talks to the real Astra gateway: app/appointment_routes.py (booking,
/// slots, doctor directory) and app/finance_routes.py (payment, reused from
/// the same consultation_id a booking creates) - not the main app backend's
/// generic purpose/reference payment endpoint (lib/features/payments),
/// which this feature deliberately doesn't go through.
class AppointmentRepositoryImpl implements AppointmentRepository {
  final AstraGatewayClient _gateway;

  AppointmentRepositoryImpl([AstraGatewayClient? gateway])
      : _gateway = gateway ?? AstraGatewayClient();

  @override
  Future<List<DoctorSummary>> listDoctors({String? specialization}) async {
    final dio = await _gateway.dio();
    final response = await dio.get(
      AstraGatewayApis.appointmentsDoctors,
      queryParameters:
          specialization != null ? {'specialization': specialization} : null,
    );
    final data = response.data as Map<String, dynamic>;
    final doctors = (data['doctors'] as List<dynamic>? ?? []);
    return doctors
        .map((d) => DoctorSummary.fromJson(d as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<String>> getSlots(String doctorId, String date) async {
    final dio = await _gateway.dio();
    final response = await dio.get(
      AstraGatewayApis.appointmentsDoctorSlots(doctorId),
      queryParameters: {'date': date},
    );
    final data = response.data as Map<String, dynamic>;
    return (data['slots'] as List<dynamic>? ?? [])
        .map((s) => s.toString())
        .toList();
  }

  @override
  Future<String> book({
    required String doctorId,
    required String date,
    required String time,
    String consultationType = 'video',
  }) async {
    final dio = await _gateway.dio();
    final response = await dio.post(AstraGatewayApis.appointmentsBook, data: {
      'doctor_id': doctorId,
      'date': date,
      'time': time,
      'consultation_type': consultationType,
    });
    final data = response.data as Map<String, dynamic>;
    final consultationId = data['consultation_id'] as String?;
    if (consultationId == null) {
      throw AppointmentException('Booking failed');
    }
    return consultationId;
  }

  @override
  Future<List<Appointment>> myAppointments() async {
    final dio = await _gateway.dio();
    final response = await dio.get(AstraGatewayApis.appointmentsMy);
    final data = response.data as Map<String, dynamic>;
    final appointments = (data['appointments'] as List<dynamic>? ?? []);
    return appointments
        .map((a) => Appointment.fromJson(a as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> cancel(String consultationId) async {
    final dio = await _gateway.dio();
    await dio.post(AstraGatewayApis.appointmentsCancel(consultationId));
  }

  @override
  Future<PaymentOrderRef> createPaymentOrder({
    required String consultationId,
    required String doctorId,
    required int amountRupees,
  }) async {
    final dio = await _gateway.dio();
    final response = await dio.post(AstraGatewayApis.financeCreateOrder, data: {
      'consultation_id': consultationId,
      'doctor_id': doctorId,
      'amount': amountRupees,
    });
    final data = response.data as Map<String, dynamic>;
    return PaymentOrderRef(
      orderId: data['order_id'] as String,
      keyId: data['key_id'] as String,
      amount: data['amount'] as int,
      currency: data['currency'] as String? ?? 'INR',
    );
  }

  @override
  Future<bool> verifyPayment({
    required String consultationId,
    required String razorpayPaymentId,
    required String razorpayOrderId,
    required String razorpaySignature,
  }) async {
    final dio = await _gateway.dio();
    final response =
        await dio.post(AstraGatewayApis.financeVerifyPayment, data: {
      'consultation_id': consultationId,
      'razorpay_payment_id': razorpayPaymentId,
      'razorpay_order_id': razorpayOrderId,
      'razorpay_signature': razorpaySignature,
    });
    final data = response.data as Map<String, dynamic>;
    return data['success'] == true;
  }
}
