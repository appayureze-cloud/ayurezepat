import '../../astra/data/astra_gateway_apis.dart';
import '../../astra/data/astra_gateway_client.dart';
import '../domain/entities/medicine_availability.dart';
import '../domain/shopify_repository.dart';
import 'shopify_dtos.dart';

/// Talks to the real Shopify medicine-catalog API on the Astra gateway.
/// `security: none`, so unlike video/companion calls this doesn't strictly
/// need the Firebase-token-exchanged bearer, but goes through
/// AstraGatewayClient anyway for a consistent base URL/timeout setup.
class ShopifyRepositoryImpl implements ShopifyRepository {
  final AstraGatewayClient _gateway;

  ShopifyRepositoryImpl([AstraGatewayClient? gateway])
      : _gateway = gateway ?? AstraGatewayClient();

  @override
  Future<MedicineAvailability> checkAvailability(String medicineName) async {
    final dio = await _gateway.dio();
    final response =
        await dio.get(AstraGatewayApis.shopifyProductSearch(medicineName));
    return MedicineSearchResponse.fromJson(response.data).toEntity();
  }
}
