import 'package:json_annotation/json_annotation.dart';

part 'case.g.dart';

enum CaseStatus {
  @JsonValue('open')
  open,
  @JsonValue('consulting')
  consulting,
  @JsonValue('treating')
  treating,
  @JsonValue('following_up')
  followingUp,
  @JsonValue('resolved')
  resolved,
  @JsonValue('closed')
  closed,
}

/// Every booking, order and treatment in the app hangs off one Case - see
/// the product flow in docs/backend/case.md. Once Astra ships (Phase 1),
/// `POST /astra/sessions` becomes the usual way a case is created; this
/// model and its repository are what the rest of the app (bookings, orders,
/// therapy) reads/writes to thread `case_id` through their requests.
@JsonSerializable()
class Case {
  final String id;
  final CaseStatus status;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  final String? specialty;

  const Case({
    required this.id,
    required this.status,
    this.createdAt,
    this.specialty,
  });

  factory Case.fromJson(Map<String, dynamic> json) => _$CaseFromJson(json);

  Map<String, dynamic> toJson() => _$CaseToJson(this);

  bool get isActive =>
      status != CaseStatus.resolved && status != CaseStatus.closed;
}
