import 'dart:async';

import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../../v2/utils/logger.dart';
import '../data/cart_repository_impl.dart';
import '../domain/cart_repository.dart';
import '../domain/entities/cart.dart';
import '../domain/entities/product.dart';

class CartPaymentCancelledException implements Exception {}

/// Orchestrates the cart + checkout + payment flow. Always talks to Astra
/// (no mock mode) - new functionality built Astra-only from the start.
class CartService {
  final CartRepository _repository;

  CartService({CartRepository? repository})
      : _repository = repository ?? CartRepositoryImpl();

  Future<List<Product>> listProducts() => _repository.listProducts();

  Future<Cart> getCart() => _repository.getCart();

  Future<Cart> addItem(String medicineName, {int quantity = 1}) =>
      _repository.addItem(medicineName, quantity: quantity);

  Future<Cart> removeItem(String productId) =>
      _repository.removeItem(productId);

  Future<List<CartOrder>> orderHistory() => _repository.orderHistory();

  /// Runs checkout -> Razorpay -> server verification.
  Future<void> checkoutAndPay(
      {String? contactPhone, String? contactEmail}) async {
    final ref = await _repository.checkout();

    final callback = await _openCheckout(ref,
        contactPhone: contactPhone, contactEmail: contactEmail);

    final verified = await _repository.verifyPayment(
      cartId: ref.cartId,
      razorpayPaymentId: callback.razorpayPaymentId,
      razorpayOrderId: callback.razorpayOrderId,
      razorpaySignature: callback.razorpaySignature,
    );

    if (!verified) {
      throw CartException('Payment could not be verified');
    }
  }

  Future<_CheckoutCallback> _openCheckout(
    CartCheckoutRef ref, {
    String? contactPhone,
    String? contactEmail,
  }) async {
    final razorpay = Razorpay();
    final completer = Completer<_CheckoutCallback>();

    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, (PaymentSuccessResponse r) {
      completer.complete(_CheckoutCallback(
        razorpayPaymentId: r.paymentId ?? '',
        razorpayOrderId: r.orderId ?? ref.orderId,
        razorpaySignature: r.signature ?? '',
      ));
    });
    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, (PaymentFailureResponse r) {
      logger.e('Razorpay error: ${r.code} ${r.message}');
      if (!completer.isCompleted) {
        if (r.code == Razorpay.PAYMENT_CANCELLED) {
          completer.completeError(CartPaymentCancelledException());
        } else {
          completer.completeError(CartException(r.message ?? 'Payment failed'));
        }
      }
    });
    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, (ExternalWalletResponse r) {});

    razorpay.open({
      'key': ref.keyId,
      'order_id': ref.orderId,
      'amount': ref.amount,
      'currency': ref.currency,
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

class _CheckoutCallback {
  final String razorpayPaymentId;
  final String razorpayOrderId;
  final String razorpaySignature;

  const _CheckoutCallback({
    required this.razorpayPaymentId,
    required this.razorpayOrderId,
    required this.razorpaySignature,
  });
}
