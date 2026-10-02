/// A server-priced Razorpay order. The amount/currency here are what the
/// backend decided to charge - the client never computes or sends a price.
class PaymentOrder {
  final String orderId;
  final String keyId;
  final num amount;
  final String currency;

  const PaymentOrder({
    required this.orderId,
    required this.keyId,
    required this.amount,
    required this.currency,
  });
}

class PaymentVerificationResult {
  final bool success;
  final String? paymentReference;
  final String? message;

  const PaymentVerificationResult({
    required this.success,
    this.paymentReference,
    this.message,
  });
}

/// What Razorpay hands back on payment success, before we've verified it
/// server-side.
class RazorpayCallbackResult {
  final String razorpayPaymentId;
  final String razorpayOrderId;
  final String razorpaySignature;

  const RazorpayCallbackResult({
    required this.razorpayPaymentId,
    required this.razorpayOrderId,
    required this.razorpaySignature,
  });
}
