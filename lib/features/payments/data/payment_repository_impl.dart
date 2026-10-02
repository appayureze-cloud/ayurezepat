import 'package:dio/dio.dart';

import '../../../api/network_api.dart';
import '../domain/entities/payment_order.dart';
import '../domain/payment_repository.dart';
import 'payment_dtos.dart';

/// Talks to the real backend `payments/orders` and `payments/verify`
/// endpoints. See docs/backend/payments.md for the contract.
class PaymentRepositoryImpl implements PaymentRepository {
  final Dio dio;

  PaymentRepositoryImpl(this.dio);

  @override
  Future<PaymentOrder> createOrder({
    required String purpose,
    required Map<String, dynamic> reference,
    String? caseId,
  }) async {
    final response = await RestClient(dio).createPaymentOrder(
      CreatePaymentOrderRequest(
        purpose: purpose,
        reference: reference,
        caseId: caseId,
      ),
    );

    if (response.success != true ||
        response.orderId == null ||
        response.keyId == null ||
        response.amount == null ||
        response.currency == null) {
      throw PaymentException(response.msg ?? 'Could not create payment order');
    }

    return PaymentOrder(
      orderId: response.orderId!,
      keyId: response.keyId!,
      amount: response.amount!,
      currency: response.currency!,
    );
  }

  @override
  Future<PaymentVerificationResult> verifyPayment({
    required String orderId,
    required RazorpayCallbackResult callback,
  }) async {
    final response = await RestClient(dio).verifyPayment(
      VerifyPaymentRequest(
        orderId: orderId,
        razorpayPaymentId: callback.razorpayPaymentId,
        razorpayOrderId: callback.razorpayOrderId,
        razorpaySignature: callback.razorpaySignature,
      ),
    );

    return PaymentVerificationResult(
      success: response.success,
      paymentReference: response.paymentReference,
      message: response.msg,
    );
  }
}

class PaymentException implements Exception {
  final String message;
  PaymentException(this.message);

  @override
  String toString() => message;
}
