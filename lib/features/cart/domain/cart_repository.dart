import 'entities/cart.dart';
import 'entities/product.dart';

class CartException implements Exception {
  final String message;
  CartException(this.message);

  @override
  String toString() => message;
}

abstract class CartRepository {
  Future<List<Product>> listProducts();

  Future<Cart> getCart();

  Future<Cart> addItem(String medicineName, {int quantity = 1});

  Future<Cart> removeItem(String productId);

  /// Creates a Shopify draft order + Razorpay order for the current cart.
  Future<CartCheckoutRef> checkout();

  Future<bool> verifyPayment({
    required String cartId,
    required String razorpayPaymentId,
    required String razorpayOrderId,
    required String razorpaySignature,
  });

  Future<List<CartOrder>> orderHistory();
}

class CartCheckoutRef {
  final String cartId;
  final String orderId;
  final String keyId;
  final int amount;
  final String currency;

  const CartCheckoutRef({
    required this.cartId,
    required this.orderId,
    required this.keyId,
    required this.amount,
    required this.currency,
  });
}
