// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'case_dtos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CaseResponse _$CaseResponseFromJson(Map<String, dynamic> json) => CaseResponse(
      success: json['success'] as bool,
      msg: json['msg'] as String?,
      data: json['data'] == null
          ? null
          : Case.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CaseResponseToJson(CaseResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'msg': instance.msg,
      'data': instance.data,
    };
