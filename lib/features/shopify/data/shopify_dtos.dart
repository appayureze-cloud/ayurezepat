import 'package:json_annotation/json_annotation.dart';

import '../domain/entities/medicine_availability.dart';

part 'shopify_dtos.g.dart';

/// `GET /api/v1/shopify/products/search/{medicine_name}` response - this
/// exact shape was observed live against astra.ayureze.in during the
/// Phase 4 audit (not a guess, unlike most of the other gateway DTOs in
/// this app, whose response schemas aren't fixed in the published spec).
@JsonSerializable()
class MedicineSearchResponse {
  @JsonKey(name: 'medicine_name')
  final String medicineName;
  @JsonKey(name: 'shopify_variant_id')
  final String? shopifyVariantId;
  @JsonKey(name: 'shopify_product_title')
  final String? shopifyProductTitle;
  @JsonKey(name: 'is_available')
  final bool isAvailable;
  @JsonKey(name: 'suggested_alternatives')
  final List<String> suggestedAlternatives;

  MedicineSearchResponse({
    required this.medicineName,
    this.shopifyVariantId,
    this.shopifyProductTitle,
    required this.isAvailable,
    this.suggestedAlternatives = const [],
  });

  factory MedicineSearchResponse.fromJson(Map<String, dynamic> json) =>
      _$MedicineSearchResponseFromJson(json);

  Map<String, dynamic> toJson() => _$MedicineSearchResponseToJson(this);

  MedicineAvailability toEntity() => MedicineAvailability(
        medicineName: medicineName,
        shopifyVariantId: shopifyVariantId,
        shopifyProductTitle: shopifyProductTitle,
        isAvailable: isAvailable,
        suggestedAlternatives: suggestedAlternatives,
      );
}
