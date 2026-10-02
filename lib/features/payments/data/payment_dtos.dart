import 'package:json_annotation/json_annotation.dart';

part 'payment_dtos.g.dart';

/// What we ask the backend to price before opening Razorpay. `purpose`
/// identifies which booking flow this is for; `reference` carries whatever
/// purpose-specific ids the backend needs to compute the authoritative
/// price server-side (doctor id, package id, coupon id, cart, etc). The
/// client never sends an amount here - the backend is the only source of
/// truth for price.
@JsonSerializable()
class CreatePaymentOrderRequest {
  final String purpose;
  @JsonKey(name: 'case_id')
  final String? caseId;
  final Map<String, dynamic> reference;

  CreatePaymentOrderRequest({
    required this.purpose,
    required this.reference,
    this.caseId,
  });

  factory CreatePaymentOrderRequest.fromJson(Map<String, dynamic> json) =>
      _$CreatePaymentOrderRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreatePaymentOrderRequestToJson(this);
}

@JsonSerializable()
class CreatePaymentOrderResponse {
  final bool success;
  final String? msg;
  @JsonKey(name: 'order_id')
  final String? orderId;
  @JsonKey(name: 'key_id')
  final String? keyId;
  final num? amount;
  final String? currency;

  CreatePaymentOrderResponse({
    required this.success,
    this.msg,
    this.orderId,
    this.keyId,
    this.amount,
    this.currency,
  });

  factory CreatePaymentOrderResponse.fromJson(Map<String, dynamic> json) =>
      _$CreatePaymentOrderResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CreatePaymentOrderResponseToJson(this);
}

@JsonSerializable()
class VerifyPaymentRequest {
  @JsonKey(name: 'order_id')
  final String orderId;
  @JsonKey(name: 'razorpay_payment_id')
  final String razorpayPaymentId;
  @JsonKey(name: 'razorpay_order_id')
  final String razorpayOrderId;
  @JsonKey(name: 'razorpay_signature')
  final String razorpaySignature;

  VerifyPaymentRequest({
    required this.orderId,
    required this.razorpayPaymentId,
    required this.razorpayOrderId,
    required this.razorpaySignature,
  });

  factory VerifyPaymentRequest.fromJson(Map<String, dynamic> json) =>
      _$VerifyPaymentRequestFromJson(json);

  Map<String, dynamic> toJson() => _$VerifyPaymentRequestToJson(this);
}

@JsonSerializable()
class VerifyPaymentResponse {
  final bool success;
  final String? msg;
  @JsonKey(name: 'payment_reference')
  final String? paymentReference;

  VerifyPaymentResponse({
    required this.success,
    this.msg,
    this.paymentReference,
  });

  factory VerifyPaymentResponse.fromJson(Map<String, dynamic> json) =>
      _$VerifyPaymentResponseFromJson(json);

  Map<String, dynamic> toJson() => _$VerifyPaymentResponseToJson(this);
}
