import 'package:dio/dio.dart';

import '../../../api/network_api.dart';
import '../domain/entities/smart_order_draft.dart';
import '../domain/smart_order_repository.dart';

class SmartOrderException implements Exception {
  final String message;
  SmartOrderException(this.message);

  @override
  String toString() => message;
}

class SmartOrderRepositoryImpl implements SmartOrderRepository {
  final Dio dio;

  SmartOrderRepositoryImpl(this.dio);

  @override
  Future<SmartOrderDraft> getDraft(String id) async {
    final response = await RestClient(dio).getSmartOrderDraft(id);
    if (response.success != true || response.data == null) {
      throw SmartOrderException(response.msg ?? 'Draft not found');
    }
    return response.data!.toEntity();
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
    await client.markSmartOrderDraftBought(id);
  }

  @override
  Future<void> markIgnored(String id) async {
    await RestClient(dio).markSmartOrderDraftIgnored(id);
  }
}
