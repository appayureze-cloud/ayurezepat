import 'package:dio/dio.dart';

import '../../../const/env.dart';
import '../data/case_repository_impl.dart';
import '../data/mock_case_repository.dart';
import '../domain/case_repository.dart';
import '../domain/entities/case.dart';

/// Resolves the right CaseRepository (real vs mock). Call
/// `CaseService.withDio(dio).ensureActiveCase()` wherever a booking/order
/// flow needs a case_id. The `dio` parameter is kept for call-site
/// compatibility (many existing call sites already have one on hand from
/// the main app backend's client) but is unused by the real path -
/// CaseRepositoryImpl talks to the Astra gateway, which has its own
/// auth/host, the same way HealthRecordService's real repository does.
class CaseService {
  final CaseRepository _repository;

  CaseService(this._repository);

  factory CaseService.withDio(Dio dio) => CaseService(
        Env.useMockCases ? MockCaseRepository() : CaseRepositoryImpl(),
      );

  Future<Case> ensureActiveCase() => _repository.ensureActiveCase();

  Future<Case> getCase(String id) => _repository.getCase(id);

  Future<Case> createCase() => _repository.createCase();
}
