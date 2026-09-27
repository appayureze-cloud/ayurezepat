import 'package:dio/dio.dart';

import '../../../const/env.dart';
import '../data/case_repository_impl.dart';
import '../data/mock_case_repository.dart';
import '../domain/case_repository.dart';
import '../domain/entities/case.dart';

/// Resolves the right CaseRepository (real vs mock) the same way
/// PaymentService does. Call `CaseService.withDio(dio).ensureActiveCase()`
/// wherever a booking/order flow needs a case_id.
class CaseService {
  final CaseRepository _repository;

  CaseService(this._repository);

  factory CaseService.withDio(Dio dio) => CaseService(
        Env.useMockCases ? MockCaseRepository() : CaseRepositoryImpl(dio),
      );

  Future<Case> ensureActiveCase() => _repository.ensureActiveCase();

  Future<Case> getCase(String id) => _repository.getCase(id);

  Future<Case> createCase() => _repository.createCase();
}
