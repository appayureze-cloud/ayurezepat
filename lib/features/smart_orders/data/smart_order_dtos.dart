import 'package:json_annotation/json_annotation.dart';

import '../domain/entities/smart_order_draft.dart';

part 'smart_order_dtos.g.dart';

@JsonSerializable()
class SmartOrderDraftResponse {
  final bool success;
  final String? msg;
  final SmartOrderDraftData? data;

  SmartOrderDraftResponse({required this.success, this.msg, this.data});

  factory SmartOrderDraftResponse.fromJson(Map<String, dynamic> json) =>
      _$SmartOrderDraftResponseFromJson(json);

  Map<String, dynamic> toJson() => _$SmartOrderDraftResponseToJson(this);
}

@JsonSerializable()
class SmartOrderDraftData {
  final String id;
  @JsonKey(name: 'case_id')
  final String caseId;
  @JsonKey(name: 'prescription_id')
  final String prescriptionId;
  final List<SmartOrderDraftItemDto> items;
  final String status;

  SmartOrderDraftData({
    required this.id,
    required this.caseId,
    required this.prescriptionId,
    required this.items,
    required this.status,
  });

  factory SmartOrderDraftData.fromJson(Map<String, dynamic> json) =>
      _$SmartOrderDraftDataFromJson(json);

  Map<String, dynamic> toJson() => _$SmartOrderDraftDataToJson(this);

  SmartOrderDraft toEntity() => SmartOrderDraft(
        id: id,
        caseId: caseId,
        prescriptionId: prescriptionId,
        items: items.map((i) => i.toEntity()).toList(),
        status: switch (status) {
          'bought' => SmartOrderDraftStatus.bought,
          'ignored' => SmartOrderDraftStatus.ignored,
          _ => SmartOrderDraftStatus.pending,
        },
      );
}

@JsonSerializable()
class SmartOrderDraftItemDto {
  @JsonKey(name: 'product_id')
  final int? productId;
  @JsonKey(name: 'variant_id')
  final int? variantId;
  final String name;
  final int quantity;
  final double price;

  SmartOrderDraftItemDto({
    this.productId,
    this.variantId,
    required this.name,
    required this.quantity,
    required this.price,
  });

  factory SmartOrderDraftItemDto.fromJson(Map<String, dynamic> json) =>
      _$SmartOrderDraftItemDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SmartOrderDraftItemDtoToJson(this);

  SmartOrderDraftItem toEntity() => SmartOrderDraftItem(
        productId: productId,
        variantId: variantId,
        name: name,
        quantity: quantity,
        price: price,
      );
}
