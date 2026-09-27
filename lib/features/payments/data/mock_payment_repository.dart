import 'dart:math';

import '../domain/entities/payment_order.dart';
import '../domain/payment_repository.dart';

/// Stands in for the backend's payments endpoints until they exist (see
/// docs/backend/payments.md), gated by Env.useMockPayments. It never opens
/// a real Razorpay checkout - there is no test key to embed in the client -
/// it just simulates network latency and a successful order/verification so
/// booking flows can be built and demoed end-to-end.
class MockPaymentRepository implements PaymentRepository {
  final Random _random = Random();

  @override
  Future<PaymentOrder> createOrder({
    required String purpose,
    required Map<String, dynamic> reference,
    String? caseId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final mockAmount = (reference['amount'] as num?) ?? 0;
    return PaymentOrder(
      orderId: 'mock_order_${_random.nextInt(1 << 32)}',
      keyId: 'mock_key',
      amount: mockAmount,
      currency: 'INR',
    );
  }

  @override
  Future<PaymentVerificationResult> verifyPayment({
    required String orderId,
    required RazorpayCallbackResult callback,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return PaymentVerificationResult(
      success: true,
      paymentReference: 'mock_verified_$orderId',
    );
  }
}
