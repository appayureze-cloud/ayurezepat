// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'smart_order_dtos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SmartOrderDraftResponse _$SmartOrderDraftResponseFromJson(
        Map<String, dynamic> json) =>
    SmartOrderDraftResponse(
      success: json['success'] as bool,
      msg: json['msg'] as String?,
      data: json['data'] == null
          ? null
          : SmartOrderDraftData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SmartOrderDraftResponseToJson(
        SmartOrderDraftResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'msg': instance.msg,
      'data': instance.data,
    };

SmartOrderDraftData _$SmartOrderDraftDataFromJson(Map<String, dynamic> json) =>
    SmartOrderDraftData(
      id: json['id'] as String,
      caseId: json['case_id'] as String,
      prescriptionId: json['prescription_id'] as String,
      items: (json['items'] as List<dynamic>)
          .map(
              (e) => SmartOrderDraftItemDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      status: json['status'] as String,
    );

Map<String, dynamic> _$SmartOrderDraftDataToJson(
        SmartOrderDraftData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'case_id': instance.caseId,
      'prescription_id': instance.prescriptionId,
      'items': instance.items,
      'status': instance.status,
    };

SmartOrderDraftItemDto _$SmartOrderDraftItemDtoFromJson(
        Map<String, dynamic> json) =>
    SmartOrderDraftItemDto(
      productId: (json['product_id'] as num?)?.toInt(),
      variantId: (json['variant_id'] as num?)?.toInt(),
      name: json['name'] as String,
      quantity: (json['quantity'] as num).toInt(),
      price: (json['price'] as num).toDouble(),
    );

Map<String, dynamic> _$SmartOrderDraftItemDtoToJson(
        SmartOrderDraftItemDto instance) =>
    <String, dynamic>{
      'product_id': instance.productId,
      'variant_id': instance.variantId,
      'name': instance.name,
      'quantity': instance.quantity,
      'price': instance.price,
    };
