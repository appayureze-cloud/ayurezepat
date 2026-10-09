import 'dart:async';

import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../../v2/utils/logger.dart';
import '../data/appointment_repository_impl.dart';
import '../domain/appointment_repository.dart';
import '../domain/entities/appointment.dart';
import '../domain/entities/doctor_summary.dart';

class AppointmentPaymentCancelledException implements Exception {}

/// Orchestrates the full booking + payment flow for the appointments
/// feature - book a real open slot, open Razorpay checkout, verify
/// server-side. Always talks to Astra (no mock mode): this is new
/// functionality built to be Astra-only from the start, unlike the legacy
/// payments feature it deliberately doesn't share a backend with.
class AppointmentService {
  final AppointmentRepository _repository;

  AppointmentService({AppointmentRepository? repository})
      : _repository = repository ?? AppointmentRepositoryImpl();

  Future<List<DoctorSummary>> listDoctors({String? specialization}) =>
      _repository.listDoctors(specialization: specialization);

  Future<List<String>> getSlots(String doctorId, String date) =>
      _repository.getSlots(doctorId, date);

  Future<List<Appointment>> myAppointments() => _repository.myAppointments();

  Future<void> cancel(String consultationId) => _repository.cancel(consultationId);

  /// Books the slot, then runs the full pay flow (price, Razorpay checkout,
  /// server verification). Throws [AppointmentPaymentCancelledException] if
  /// the user dismisses Razorpay, or [AppointmentException] if
  /// booking/pricing/verification fails.
  Future<Appointment> bookAndPay({
    required String doctorId,
    required String date,
    required String time,
    required int amountRupees,
    String consultationType = 'video',
    String? contactPhone,
    String? contactEmail,
  }) async {
    final consultationId = await _repository.book(
      doctorId: doctorId,
      date: date,
      time: time,
      consultationType: consultationType,
    );

    final order = await _repository.createPaymentOrder(
      consultationId: consultationId,
      doctorId: doctorId,
      amountRupees: amountRupees,
    );

    final callback = await _openCheckout(
      order,
      contactPhone: contactPhone,
      contactEmail: contactEmail,
    );

    final verified = await _repository.verifyPayment(
      consultationId: consultationId,
      razorpayPaymentId: callback.razorpayPaymentId,
      razorpayOrderId: callback.razorpayOrderId,
      razorpaySignature: callback.razorpaySignature,
    );

    if (!verified) {
      throw AppointmentException('Payment could not be verified');
    }

    final appointments = await myAppointments();
    return appointments.firstWhere(
      (a) => a.consultationId == consultationId,
      orElse: () => throw AppointmentException('Booked, but could not reload appointment'),
    );
  }

  Future<_CheckoutCallback> _openCheckout(
    PaymentOrderRef order, {
    String? contactPhone,
    String? contactEmail,
  }) async {
    final razorpay = Razorpay();
    final completer = Completer<_CheckoutCallback>();

    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, (PaymentSuccessResponse r) {
      completer.complete(_CheckoutCallback(
        razorpayPaymentId: r.paymentId ?? '',
        razorpayOrderId: r.orderId ?? order.orderId,
        razorpaySignature: r.signature ?? '',
      ));
    });
    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, (PaymentFailureResponse r) {
      logger.e('Razorpay error: ${r.code} ${r.message}');
      if (!completer.isCompleted) {
        if (r.code == Razorpay.PAYMENT_CANCELLED) {
          completer.completeError(AppointmentPaymentCancelledException());
        } else {
          completer.completeError(AppointmentException(r.message ?? 'Payment failed'));
        }
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
