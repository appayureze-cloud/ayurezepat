class CartListResponse {
  bool? success;
  List<CartItem>? data;
  String? msg;

  CartListResponse({this.success, this.data, this.msg});

  CartListResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = <CartItem>[];
      json['data'].forEach((v) {
        data!.add(new CartItem.fromJson(v));
      });
    }
    msg = json['msg'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['msg'] = this.msg;
    return data;
  }
}

class CartItem {
  int? id;
  int? productId;
  int? variantId;
  String? title;
  String? variant;
  double? price;
  double? originalPrice;
  double? discountPercent;
  String? imageUrl;
  int? quantity;
  double? total;
  String? sku;

  CartItem(
      {this.id,
      this.productId,
      this.variantId,
      this.title,
      this.variant,
      this.price,
      this.originalPrice,
      this.discountPercent,
      this.imageUrl,
      this.quantity,
      this.total,
      this.sku});

  CartItem.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    productId = json['product_id'];
    variantId = json['variant_id'];
    title = json['title'];
    variant = json['variant'];
    price = double.tryParse('${json['price']}');
    originalPrice = double.tryParse('${json['original_price']}');
    discountPercent = double.tryParse('${json['discount_percent']}');
    imageUrl = json['image_url'];
    quantity = json['quantity'];
    total = double.tryParse('${json['total']}');
    sku = json['sku'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['product_id'] = this.productId;
    data['variant_id'] = this.variantId;
    data['title'] = this.title;
    data['variant'] = this.variant;
    data['price'] = this.price;
    data['original_price'] = this.originalPrice;
    data['discount_percent'] = this.discountPercent;
    data['image_url'] = this.imageUrl;
    data['quantity'] = this.quantity;
    data['total'] = this.total;
    data['sku'] = this.sku;
    return data;
  }
}
