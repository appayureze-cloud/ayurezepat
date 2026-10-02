import '../domain/entities/medicine_availability.dart';
import '../domain/shopify_repository.dart';

/// Stands in for the real Shopify catalog API until Env.useMockShopify is
/// flipped. Always reports available, for a frictionless demo. See
/// docs/backend/astra.md.
class MockShopifyRepository implements ShopifyRepository {
  @override
  Future<MedicineAvailability> checkAvailability(String medicineName) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return MedicineAvailability(
      medicineName: medicineName,
      shopifyProductTitle: medicineName,
      isAvailable: true,
    );
  }
}
