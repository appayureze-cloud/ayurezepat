// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prescription_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PrescriptionItem _$PrescriptionItemFromJson(Map<String, dynamic> json) =>
    PrescriptionItem(
      productSku: json['product_sku'] as String?,
      name: json['name'] as String,
      dose: json['dose'] as String,
      frequency: json['frequency'] as String,
      durationDays: (json['duration_days'] as num).toInt(),
      timing: json['timing'] as String,
      instructions: json['instructions'] as String?,
    );

Map<String, dynamic> _$PrescriptionItemToJson(PrescriptionItem instance) =>
    <String, dynamic>{
      'product_sku': instance.productSku,
      'name': instance.name,
      'dose': instance.dose,
      'frequency': instance.frequency,
      'duration_days': instance.durationDays,
      'timing': instance.timing,
      'instructions': instance.instructions,
    };
