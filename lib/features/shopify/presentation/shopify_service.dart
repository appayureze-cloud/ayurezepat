import '../../../const/env.dart';
import '../data/mock_shopify_repository.dart';
import '../data/shopify_repository_impl.dart';
import '../domain/entities/medicine_availability.dart';
import '../domain/shopify_repository.dart';

/// Resolves the real vs mock ShopifyRepository, the same pattern as
/// MedicineReminderService/DocumentService.
class ShopifyService {
  final ShopifyRepository _repository;

  ShopifyService(this._repository);

  factory ShopifyService.create() => ShopifyService(
        Env.useMockShopify ? MockShopifyRepository() : ShopifyRepositoryImpl(),
      );

  Future<MedicineAvailability> checkAvailability(String medicineName) =>
      _repository.checkAvailability(medicineName);
}
