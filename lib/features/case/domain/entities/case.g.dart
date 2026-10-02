// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'case.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Case _$CaseFromJson(Map<String, dynamic> json) => Case(
      id: json['id'] as String,
      status: $enumDecode(_$CaseStatusEnumMap, json['status']),
      createdAt: json['created_at'] as String?,
      specialty: json['specialty'] as String?,
    );

Map<String, dynamic> _$CaseToJson(Case instance) => <String, dynamic>{
      'id': instance.id,
      'status': _$CaseStatusEnumMap[instance.status]!,
      'created_at': instance.createdAt,
      'specialty': instance.specialty,
    };

const _$CaseStatusEnumMap = {
  CaseStatus.open: 'open',
  CaseStatus.consulting: 'consulting',
  CaseStatus.treating: 'treating',
  CaseStatus.followingUp: 'following_up',
  CaseStatus.resolved: 'resolved',
  CaseStatus.closed: 'closed',
};
