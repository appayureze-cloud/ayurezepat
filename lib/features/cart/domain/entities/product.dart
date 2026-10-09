/// A Shopify catalog item, as returned by GET /api/v1/shopify/products/available
/// (app/smart_auto_cart.py's get_available_medicines - confirmed live,
/// 619 real products, no auth required).
class Product {
  final String name;
  final String productId;
  final String variantId;
  final double priceNumeric;
  final bool available;
  final String? vendor;

  const Product({
    required this.name,
    required this.productId,
    required this.variantId,
    required this.priceNumeric,
    required this.available,
    this.vendor,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        name: json['name'] as String? ?? json['title'] as String? ?? '',
        productId: json['product_id']?.toString() ?? '',
        variantId: json['variant_id']?.toString() ?? '',
        priceNumeric: (json['price_numeric'] as num?)?.toDouble() ?? 0,
        available: json['available'] as bool? ?? false,
        vendor: json['vendor'] as String?,
      );
}
