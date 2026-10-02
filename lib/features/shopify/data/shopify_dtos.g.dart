// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shopify_dtos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MedicineSearchResponse _$MedicineSearchResponseFromJson(
        Map<String, dynamic> json) =>
    MedicineSearchResponse(
      medicineName: json['medicine_name'] as String,
      shopifyVariantId: json['shopify_variant_id'] as String?,
      shopifyProductTitle: json['shopify_product_title'] as String?,
      isAvailable: json['is_available'] as bool,
      suggestedAlternatives: (json['suggested_alternatives'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$MedicineSearchResponseToJson(
        MedicineSearchResponse instance) =>
    <String, dynamic>{
      'medicine_name': instance.medicineName,
      'shopify_variant_id': instance.shopifyVariantId,
      'shopify_product_title': instance.shopifyProductTitle,
      'is_available': instance.isAvailable,
      'suggested_alternatives': instance.suggestedAlternatives,
    };
