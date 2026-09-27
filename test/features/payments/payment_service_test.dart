import 'package:doctro_patient/features/payments/domain/payment_repository.dart';
import 'package:doctro_patient/features/payments/presentation/payment_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PaymentService (mock backend)', () {
    test('charge returns a verified payment reference without opening Razorpay',
        () async {
      // Env.useMockPayments defaults to true, so PaymentService() here uses
      // MockPaymentRepository and never touches the Razorpay SDK - safe to
      // run in a plain Dart test environment.
      final service = PaymentService();

      final reference = await service.charge(
        purpose: PaymentRepository.purposeAppointment,
        reference: {'doctor_id': 1, 'amount': 500},
      );

      expect(reference, isNotEmpty);
      expect(reference, startsWith('mock_verified_'));
    });
  });
}
