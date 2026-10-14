/// One line item in a patient's cart - matches app/cart_routes.py's stored
/// item shape ({product_id, variant_id, name, quantity, price}).
class CartItem {
  final String productId;
  final String variantId;
  final String name;
  final int quantity;
  final double price;

  const CartItem({
    required this.productId,
    required this.variantId,
    required this.name,
    required this.quantity,
    required this.price,
  });

  double get lineTotal => price * quantity;

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
        productId: json['product_id']?.toString() ?? '',
        variantId: json['variant_id']?.toString() ?? '',
        name: json['name'] as String? ?? '',
        quantity: (json['quantity'] as num?)?.toInt() ?? 1,
        price: (json['price'] as num?)?.toDouble() ?? 0,
      );
}

/// A cart (`carts` table row) - GET /api/v1/cart returns the patient's
/// single active cart, creating one if none exists.
class Cart {
  final String id;
  final List<CartItem> items;
  final String status;
  final int totalAmount;

  const Cart({
    required this.id,
    required this.items,
    required this.status,
    required this.totalAmount,
  });

  factory Cart.fromJson(Map<String, dynamic> json) => Cart(
        id: json['id']?.toString() ?? '',
        items: (json['items'] as List<dynamic>? ?? [])
            .map((i) => CartItem.fromJson(i as Map<String, dynamic>))
            .toList(),
        status: json['status'] as String? ?? 'active',
        totalAmount: (json['total_amount'] as num?)?.toInt() ?? 0,
      );
}

/// A past (non-active) cart, shown in order history.
class CartOrder {
  final String id;
  final List<CartItem> items;
  final String status;
  final int totalAmount;
  final String? invoiceUrl;
  final DateTime updatedAt;

  const CartOrder({
    required this.id,
    required this.items,
    required this.status,
    required this.totalAmount,
    required this.updatedAt,
    this.invoiceUrl,
  });

  factory CartOrder.fromJson(Map<String, dynamic> json) => CartOrder(
        id: json['id']?.toString() ?? '',
        items: (json['items'] as List<dynamic>? ?? [])
            .map((i) => CartItem.fromJson(i as Map<String, dynamic>))
            .toList(),
        status: json['status'] as String? ?? '',
        totalAmount: (json['total_amount'] as num?)?.toInt() ?? 0,
        invoiceUrl: json['invoice_url'] as String?,
        updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? '') ??
            DateTime.now(),
      );
}
