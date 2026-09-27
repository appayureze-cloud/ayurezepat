import 'dart:async';

import 'package:dio/dio.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../../const/env.dart';
import '../../../v2/utils/logger.dart';
import '../data/mock_payment_repository.dart';
import '../data/payment_repository_impl.dart';
import '../domain/entities/payment_order.dart';
import '../domain/payment_repository.dart';

class PaymentCancelledException implements Exception {}

/// Single entry point every payment screen goes through. Replaces each
/// screen's own ad-hoc Razorpay wiring and its own trust-the-client body
/// (amount/discount_price/payment_status sent straight to the booking
/// endpoint). Call [charge] with a purpose + pricing reference; it returns
/// an opaque, server-verified `paymentReference` to send to the booking
/// endpoint instead.
class PaymentService {
  final PaymentRepository _repository;

  PaymentService({PaymentRepository? repository})
      : _repository = repository ??
            (Env.useMockPayments
                ? MockPaymentRepository()
                : PaymentRepositoryImpl(Dio()));

  /// Creates a factory bound to an authenticated Dio instance (from
  /// RetroApi().dioData(context)) for the real backend, still honoring the
  /// mock flag for local/dev builds.
  factory PaymentService.withDio(Dio dio) => PaymentService(
        repository: Env.useMockPayments
            ? MockPaymentRepository()
            : PaymentRepositoryImpl(dio),
      );

  /// Runs the full pay flow: price with the backend, open Razorpay (skipped
  /// under the mock repository), verify server-side. Throws
  /// [PaymentCancelledException] if the user dismisses Razorpay, or
  /// [PaymentException] if pricing/verification fails.
  Future<String> charge({
    required String purpose,
    required Map<String, dynamic> reference,
    String? caseId,
    String? contactPhone,
    String? contactEmail,
  }) async {
    final order = await _repository.createOrder(
      purpose: purpose,
      reference: reference,
      caseId: caseId,
    );

    final callback = await _openCheckout(
      order,
      contactPhone: contactPhone,
      contactEmail: contactEmail,
    );

    final verification = await _repository.verifyPayment(
      orderId: order.orderId,
      callback: callback,
    );

    if (verification.success != true || verification.paymentReference == null) {
      throw PaymentException(
          verification.message ?? 'Payment could not be verified');
    }

    return verification.paymentReference!;
  }

  Future<RazorpayCallbackResult> _openCheckout(
    PaymentOrder order, {
    String? contactPhone,
    String? contactEmail,
  }) async {
    if (Env.useMockPayments) {
      // No real Razorpay key to embed for a mock flow - simulate the
      // callback the SDK would have delivered on success.
      return RazorpayCallbackResult(
        razorpayPaymentId: 'mock_pay_${order.orderId}',
        razorpayOrderId: order.orderId,
        razorpaySignature: 'mock_signature',
      );
    }

    final razorpay = Razorpay();
    final completer = Completer<RazorpayCallbackResult>();

    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, (PaymentSuccessResponse r) {
      completer.complete(RazorpayCallbackResult(
        razorpayPaymentId: r.paymentId ?? '',
        razorpayOrderId: r.orderId ?? order.orderId,
        razorpaySignature: r.signature ?? '',
      ));
    });
    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, (PaymentFailureResponse r) {
      logger.e('Razorpay error: ${r.code} ${r.message}');
      if (!completer.isCompleted) {
        completer.completeError(PaymentCancelledException());
      }
    });
    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, (ExternalWalletResponse r) {});

    razorpay.open({
      'key': order.keyId,
      'order_id': order.orderId,
      'amount': order.amount,
      'currency': order.currency,
      'name': 'Ayureze Healthcare',
      'image': 'https://ayureze.org/images/upload/680ce4e79bca1.png',
      'prefill': {
        'contact': contactPhone ?? '',
        'email': contactEmail ?? '',
      },
    });

    try {
      return await completer.future;
    } finally {
      razorpay.clear();
    }
  }
}
