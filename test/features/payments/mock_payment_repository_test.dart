import 'package:doctro_patient/features/payments/data/mock_payment_repository.dart';
import 'package:doctro_patient/features/payments/domain/entities/payment_order.dart';
import 'package:doctro_patient/features/payments/domain/payment_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MockPaymentRepository', () {
    late PaymentRepository repository;

    setUp(() {
      repository = MockPaymentRepository();
    });

    test('createOrder returns an order for a supported purpose', () async {
      final order = await repository.createOrder(
        purpose: PaymentRepository.purposeAppointment,
        reference: {'doctor_id': 1, 'amount': 500},
      );

      expect(order.orderId, isNotEmpty);
      expect(order.keyId, isNotEmpty);
      expect(order.currency, 'INR');
      expect(order.amount, 500);
    });

    test(
        'verifyPayment always succeeds and returns a reference tied to the order',
        () async {
      final order = await repository.createOrder(
        purpose: PaymentRepository.purposeMedicineOrder,
        reference: {'line_items': []},
      );

      final result = await repository.verifyPayment(
        orderId: order.orderId,
        callback: RazorpayCallbackResult(
          razorpayPaymentId: 'pay_1',
          razorpayOrderId: order.orderId,
          razorpaySignature: 'sig',
        ),
      );

      expect(result.success, isTrue);
      expect(result.paymentReference, contains(order.orderId));
    });
  });
}
