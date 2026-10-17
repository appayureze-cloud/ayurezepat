import 'package:dio/dio.dart';

import '../../../const/env.dart';
import '../domain/astra_repository.dart';
import 'astra_repository_impl.dart';
import 'mock_astra_repository.dart';
import 'partial_mock_astra_repository.dart';

/// Resolves the real vs mock AstraRepository, the same pattern as
/// PaymentService/CaseService.
class AstraService {
  final AstraRepository repository;

  AstraService(this.repository);

  /// Env.useMockAstra fully mocked vs fully real. When real, checkin and
  /// ackReminder are still routed to the mock - confirmed via a live
  /// `curl` to 404 at the router level (route doesn't exist yet), see
  /// PartialMockAstraRepository's doc comment.
  factory AstraService.withDio(Dio dio) => AstraService(
        Env.useMockAstra
            ? MockAstraRepository()
            : PartialMockAstraRepository(AstraRepositoryImpl(dio)),
      );
}
