import 'dart:math';

import '../../../const/prefConstatnt.dart';
import '../../../const/preference.dart';
import '../domain/case_repository.dart';
import '../domain/entities/case.dart';

const Map<CaseStatus, String> _statusNames = {
  CaseStatus.open: 'open',
  CaseStatus.consulting: 'consulting',
  CaseStatus.treating: 'treating',
  CaseStatus.followingUp: 'following_up',
  CaseStatus.resolved: 'resolved',
  CaseStatus.closed: 'closed',
};

CaseStatus _statusFromName(String name) => _statusNames.entries
    .firstWhere((entry) => entry.value == name,
        orElse: () => const MapEntry(CaseStatus.open, 'open'))
    .key;

/// Stands in for the backend's case endpoints until they exist (see
/// docs/backend/case.md), gated by Env.useMockCases. Keeps a single fake
/// case per install (getCase ignores its `id` and always returns this one
/// case's status - there's only ever one "active" case in the mock, unlike
/// a real backend) so `case_id` plumbing through bookings/orders can be
/// built and tested before the backend ships it. Also persists status
/// locally so `MockAstraRepository.resolveCase` can actually close a case
/// end to end in demos - which only works when Env.useMockAstra and
/// Env.useMockCases agree, since they're independent flags.
class MockCaseRepository implements CaseRepository {
  final Random _random = Random();

  @override
  Future<Case> ensureActiveCase() async {
    final cachedId = SharedPreferenceHelper.getString(Preferences.activeCaseId);
    if (cachedId != null && cachedId.isNotEmpty) {
      final cached = await getCase(cachedId);
      if (cached.isActive) return cached;
    }
    return createCase();
  }

  @override
  Future<Case> getCase(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final statusName =
        SharedPreferenceHelper.getString(Preferences.activeCaseStatus) ?? '';
    return Case(id: id, status: _statusFromName(statusName));
  }

  @override
  Future<Case> createCase() async {
    await Future.delayed(const Duration(milliseconds: 100));
    final id = 'mock_case_${_random.nextInt(1 << 32)}';
    await SharedPreferenceHelper.setString(Preferences.activeCaseId, id);
    await SharedPreferenceHelper.setString(
        Preferences.activeCaseStatus, _statusNames[CaseStatus.open]!);
    return Case(id: id, status: CaseStatus.open);
  }
}
