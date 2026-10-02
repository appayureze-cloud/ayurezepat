import 'entities/payment_order.dart';

/// The one place that talks to the backend's payments endpoints. Payment
/// screens depend on this abstraction (via [PaymentService]), never on Dio
/// or RestClient directly.
abstract class PaymentRepository {
  /// Purpose identifiers understood by the backend contract.
  static const String purposeAppointment = 'appointment';
  static const String purposeTherapy = 'therapy';
  static const String purposeMedicineOrder = 'medicine_order';

  /// Asks the backend to price and create a Razorpay order for the given
  /// [purpose]. [reference] carries whatever purpose-specific context the
  /// backend needs to compute the price server-side (doctor id, package id,
  /// coupon id, cart contents, ...) - never a client-computed amount.
  Future<PaymentOrder> createOrder({
    required String purpose,
    required Map<String, dynamic> reference,
    String? caseId,
  });

  /// Verifies a Razorpay payment server-side (signature + order match)
  /// and returns an opaque reference the booking call can send instead of
  /// a raw payment id.
  Future<PaymentVerificationResult> verifyPayment({
    required String orderId,
    required RazorpayCallbackResult callback,
  });
}
