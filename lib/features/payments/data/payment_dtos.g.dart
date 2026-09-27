// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_dtos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreatePaymentOrderRequest _$CreatePaymentOrderRequestFromJson(
        Map<String, dynamic> json) =>
    CreatePaymentOrderRequest(
      purpose: json['purpose'] as String,
      reference: json['reference'] as Map<String, dynamic>,
      caseId: json['caseId'] as String?,
    );

Map<String, dynamic> _$CreatePaymentOrderRequestToJson(
        CreatePaymentOrderRequest instance) =>
    <String, dynamic>{
      'purpose': instance.purpose,
      'caseId': instance.caseId,
      'reference': instance.reference,
    };

CreatePaymentOrderResponse _$CreatePaymentOrderResponseFromJson(
        Map<String, dynamic> json) =>
    CreatePaymentOrderResponse(
      success: json['success'] as bool,
      msg: json['msg'] as String?,
      orderId: json['order_id'] as String?,
      keyId: json['key_id'] as String?,
      amount: json['amount'] as num?,
      currency: json['currency'] as String?,
    );

Map<String, dynamic> _$CreatePaymentOrderResponseToJson(
        CreatePaymentOrderResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'msg': instance.msg,
      'order_id': instance.orderId,
      'key_id': instance.keyId,
      'amount': instance.amount,
      'currency': instance.currency,
    };

VerifyPaymentRequest _$VerifyPaymentRequestFromJson(
        Map<String, dynamic> json) =>
    VerifyPaymentRequest(
      orderId: json['order_id'] as String,
      razorpayPaymentId: json['razorpay_payment_id'] as String,
      razorpayOrderId: json['razorpay_order_id'] as String,
      razorpaySignature: json['razorpay_signature'] as String,
    );

Map<String, dynamic> _$VerifyPaymentRequestToJson(
        VerifyPaymentRequest instance) =>
    <String, dynamic>{
      'order_id': instance.orderId,
      'razorpay_payment_id': instance.razorpayPaymentId,
      'razorpay_order_id': instance.razorpayOrderId,
      'razorpay_signature': instance.razorpaySignature,
    };

VerifyPaymentResponse _$VerifyPaymentResponseFromJson(
        Map<String, dynamic> json) =>
    VerifyPaymentResponse(
      success: json['success'] as bool,
      msg: json['msg'] as String?,
      paymentReference: json['payment_reference'] as String?,
    );

Map<String, dynamic> _$VerifyPaymentResponseToJson(
        VerifyPaymentResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'msg': instance.msg,
      'payment_reference': instance.paymentReference,
    };
