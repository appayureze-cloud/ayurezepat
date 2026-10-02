import 'package:dio/dio.dart';

import '../../../const/env.dart';
import '../domain/entities/smart_order_draft.dart';
import '../domain/smart_order_repository.dart';
import 'mock_smart_order_repository.dart';
import 'smart_order_repository_impl.dart';

class SmartOrderService {
  final SmartOrderRepository _repository;

  SmartOrderService(this._repository);

  factory SmartOrderService.withDio(Dio dio) => SmartOrderService(
        Env.useMockSmartOrders
            ? MockSmartOrderRepository()
            : SmartOrderRepositoryImpl(dio),
      );

  Future<SmartOrderDraft> getDraft(String id) => _repository.getDraft(id);

  Future<void> markBought(String id) => _repository.markBought(id);

  Future<void> markIgnored(String id) => _repository.markIgnored(id);
}
