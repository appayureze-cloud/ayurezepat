import 'package:json_annotation/json_annotation.dart';

part 'prescription_item.g.dart';

/// One line item of a structured prescription. Replaces parsing the
/// untyped `medicines` free-text field (see docs/backend/prescriptions.md).
@JsonSerializable()
class PrescriptionItem {
  @JsonKey(name: 'product_sku')
  final String? productSku;
  final String name;
  final String dose;
  final String frequency;
  @JsonKey(name: 'duration_days')
  final int durationDays;
  final String timing;
  final String? instructions;

  const PrescriptionItem({
    this.productSku,
    required this.name,
    required this.dose,
    required this.frequency,
    required this.durationDays,
    required this.timing,
    this.instructions,
  });

  factory PrescriptionItem.fromJson(Map<String, dynamic> json) =>
      _$PrescriptionItemFromJson(json);

  Map<String, dynamic> toJson() => _$PrescriptionItemToJson(this);
}
