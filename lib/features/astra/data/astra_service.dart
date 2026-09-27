import 'package:dio/dio.dart';

import '../../../const/env.dart';
import '../domain/astra_repository.dart';
import 'astra_repository_impl.dart';
import 'mock_astra_repository.dart';

/// Resolves the real vs mock AstraRepository, the same pattern as
/// PaymentService/CaseService.
class AstraService {
  final AstraRepository repository;

  AstraService(this.repository);

  factory AstraService.withDio(Dio dio) => AstraService(
        Env.useMockAstra ? MockAstraRepository() : AstraRepositoryImpl(dio),
      );
}
