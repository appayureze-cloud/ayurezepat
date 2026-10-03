import 'package:dio/dio.dart';

import '../../../api/network_api.dart';
import '../../astra/data/astra_gateway_apis.dart';
import '../../astra/data/astra_gateway_client.dart';
import '../domain/entities/smart_order_draft.dart';
import '../domain/smart_order_repository.dart';
import 'smart_order_dtos.dart';

class SmartOrderException implements Exception {
  final String message;
  SmartOrderException(this.message);

  @override
  String toString() => message;
}

/// Talks to the real Astra gateway's smart-order endpoints
/// (GET/POST /api/v1/shopify/smart-orders/{id}[/bought|/ignore]), not the
/// main app backend - the originally speculated
/// `{Apis.baseUrl}smart_orders/{id}` (Laravel) routes return a genuine 404,
/// never implemented there. The real backend lives in Astra instead (see
/// app/unified_prescription_workflow.py's smart-order creation step and
/// app/smart_auto_cart.py's /smart-orders/* routes).
///
/// `dio` is still needed for /addtocart and /cart (the main app's own
/// Shopify cart, which markBought() adds items to) - those remain on the
/// main backend, unrelated to the draft itself.
class SmartOrderRepositoryImpl implements SmartOrderRepository {
  final Dio dio;
  final AstraGatewayClient _gateway;

  SmartOrderRepositoryImpl(this.dio, [AstraGatewayClient? gateway])
      : _gateway = gateway ?? AstraGatewayClient();

  @override
  Future<SmartOrderDraft> getDraft(String id) async {
    final astraDio = await _gateway.dio();
    final response = await astraDio.get(AstraGatewayApis.smartOrderGet(id));
    return SmartOrderDraftData.fromJson(response.data).toEntity();
  }

  @override
  Future<void> markBought(String id) async {
    final draft = await getDraft(id);
    final client = RestClient(dio);

    // Idempotency guard: if a previous call added some items then failed
    // partway (network blip), a retry must not re-add the ones that
    // already made it into the cart.
    final cart = await client.getCartItems();
    final alreadyInCart = (cart.data ?? [])
        .map((item) => item.variantId)
        .whereType<int>()
        .toSet();

    for (final item in draft.items) {
      if (item.variantId != null && alreadyInCart.contains(item.variantId)) {
        continue;
      }
      await client.addtocart({
        'product_id': item.productId,
        'variant_id': item.variantId,
        'quantity': item.quantity,
        'price': item.price,
        'remove': false,
      });
    }

    final astraDio = await _gateway.dio();
    await astraDio.post(AstraGatewayApis.smartOrderBought(id));
  }

  @override
  Future<void> markIgnored(String id) async {
    final astraDio = await _gateway.dio();
    await astraDio.post(AstraGatewayApis.smartOrderIgnore(id));
  }
}
