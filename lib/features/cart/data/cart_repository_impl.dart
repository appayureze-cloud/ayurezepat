import '../../astra/data/astra_gateway_apis.dart';
import '../../astra/data/astra_gateway_client.dart';
import '../domain/cart_repository.dart';
import '../domain/entities/cart.dart';
import '../domain/entities/product.dart';

/// Talks to the real Astra gateway: app/cart_routes.py (cart/checkout) and
/// app/smart_auto_cart.py's product catalog - not the main app backend's
/// Laravel medicine/cart/checkout flow (lib/v2/ui/medicine), which this
/// feature deliberately doesn't share a backend with.
class CartRepositoryImpl implements CartRepository {
  final AstraGatewayClient _gateway;

  CartRepositoryImpl([AstraGatewayClient? gateway])
      : _gateway = gateway ?? AstraGatewayClient();

  @override
  Future<List<Product>> listProducts() async {
    final dio = await _gateway.dio();
    final response = await dio.get(AstraGatewayApis.shopifyProductsAvailable);
    final data = response.data as Map<String, dynamic>;
    final medicines = (data['medicines'] as List<dynamic>? ?? []);
    return medicines
        .map((m) => Product.fromJson(m as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Cart> getCart() async {
    final dio = await _gateway.dio();
    final response = await dio.get(AstraGatewayApis.cartGet);
    return Cart.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<Cart> addItem(String medicineName, {int quantity = 1}) async {
    final dio = await _gateway.dio();
    await dio.post(AstraGatewayApis.cartAddItem, data: {
      'medicine_name': medicineName,
      'quantity': quantity,
    });
    return getCart();
  }

  @override
  Future<Cart> removeItem(String productId) async {
    final dio = await _gateway.dio();
    await dio.delete(AstraGatewayApis.cartRemoveItem(productId));
    return getCart();
  }

  @override
  Future<CartCheckoutRef> checkout() async {
    final dio = await _gateway.dio();
    final response = await dio.post(AstraGatewayApis.cartCheckout);
    final data = response.data as Map<String, dynamic>;
    return CartCheckoutRef(
      cartId: data['cart_id'] as String,
      orderId: data['razorpay_order_id'] as String,
      keyId: data['key_id'] as String,
      amount: data['amount'] as int,
      currency: data['currency'] as String? ?? 'INR',
    );
  }

  @override
  Future<bool> verifyPayment({
    required String cartId,
    required String razorpayPaymentId,
    required String razorpayOrderId,
    required String razorpaySignature,
  }) async {
    final dio = await _gateway.dio();
    final response = await dio.post(AstraGatewayApis.cartVerifyPayment, data: {
      'cart_id': cartId,
      'razorpay_payment_id': razorpayPaymentId,
      'razorpay_order_id': razorpayOrderId,
      'razorpay_signature': razorpaySignature,
    });
    final data = response.data as Map<String, dynamic>;
    return data['success'] == true;
  }

  @override
  Future<List<CartOrder>> orderHistory() async {
    final dio = await _gateway.dio();
    final response = await dio.get(AstraGatewayApis.cartOrders);
    final data = response.data as Map<String, dynamic>;
    final orders = (data['orders'] as List<dynamic>? ?? []);
    return orders
        .map((o) => CartOrder.fromJson(o as Map<String, dynamic>))
        .toList();
  }
}
