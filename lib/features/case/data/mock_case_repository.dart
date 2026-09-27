import 'dart:math';

import '../../../const/prefConstatnt.dart';
import '../../../const/preference.dart';
import '../domain/case_repository.dart';
import '../domain/entities/case.dart';

/// Stands in for the backend's case endpoints until they exist (see
/// docs/backend/case.md), gated by Env.useMockCases. Keeps a single fake
/// case per install so `case_id` plumbing through bookings/orders can be
/// built and tested before the backend ships it.
class MockCaseRepository implements CaseRepository {
  final Random _random = Random();

  @override
  Future<Case> ensureActiveCase() async {
    final cachedId = SharedPreferenceHelper.getString(Preferences.activeCaseId);
    if (cachedId != null && cachedId.isNotEmpty) {
      return Case(id: cachedId, status: CaseStatus.open);
    }
    return createCase();
  }

  @override
  Future<Case> getCase(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return Case(id: id, status: CaseStatus.open);
  }

  @override
  Future<Case> createCase() async {
    await Future.delayed(const Duration(milliseconds: 100));
    final id = 'mock_case_${_random.nextInt(1 << 32)}';
    await SharedPreferenceHelper.setString(Preferences.activeCaseId, id);
    return Case(id: id, status: CaseStatus.open);
  }
}
