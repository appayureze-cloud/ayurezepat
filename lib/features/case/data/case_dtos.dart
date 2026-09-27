import 'package:json_annotation/json_annotation.dart';

import '../domain/entities/case.dart';

part 'case_dtos.g.dart';

@JsonSerializable()
class CaseResponse {
  final bool success;
  final String? msg;
  final Case? data;

  CaseResponse({required this.success, this.msg, this.data});

  factory CaseResponse.fromJson(Map<String, dynamic> json) =>
      _$CaseResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CaseResponseToJson(this);
}
