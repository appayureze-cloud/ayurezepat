import 'package:doctro_patient/model/v2/login_model.dart';
import 'package:doctro_patient/model/v2/medicine/cart_list_response.dart';

class MedicineDetailsResponse {
  bool? success;
  MedicineDetails? data;
  String? msg;

  MedicineDetailsResponse({this.success, this.data, this.msg});

  MedicineDetailsResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null
        ? new MedicineDetails.fromJson(json['data'])
        : null;
    msg = json['msg'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['msg'] = this.msg;
    return data;
  }
}

class MedicineDetails {
  int? id;
  String? title;
  String? description;
  String? image;
  double? price;
  double? originalPrice;
  double? discountPercent;
  List<Variants>? variants;
  List<MedicineOptions>? options;
  List<MedicineReview>? reviews;
  List<MedicineImage>? images;
  double? averageRating;
  int? ratingsCount;
  bool? cartStatus;
  List<CartItem>? cartItems;

  MedicineDetails({
    this.id,
    this.title,
    this.description,
    this.image,
    this.price,
    this.originalPrice,
    this.discountPercent,
    this.variants,
    this.options,
    this.images,
    this.reviews,
    this.averageRating,
    this.ratingsCount,
    this.cartStatus,
    this.cartItems,
  });

  MedicineDetails.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    description = json['description'];
    image = json['image'];
    price = double.tryParse('${json['price']}');
    originalPrice = double.tryParse('${json['original_price']}');
    discountPercent = double.tryParse('${json['discount_percent']}');
    if (json['variants'] != null) {
      variants = <Variants>[];
      json['variants'].forEach((v) {
        variants!.add(new Variants.fromJson(v));
      });
    }
    if (json['options'] != null) {
      options = <MedicineOptions>[];
      json['options'].forEach((v) {
        options!.add(new MedicineOptions.fromJson(v));
      });
    }
    if (json['reviews'] != null) {
      reviews = <MedicineReview>[];
      json['reviews'].forEach((v) {
        reviews!.add(new MedicineReview.fromJson(v));
      });
    }
    if (json['images'] != null) {
      images = <MedicineImage>[];
      json['images'].forEach((v) {
        images!.add(new MedicineImage.fromJson(v));
      });
    }
    averageRating = double.tryParse('${json['average_rating']}');
    ratingsCount = json['ratings_count'];
    cartStatus = json['cart_status'];
    if (json['cart_items'] != null) {
      cartItems = <CartItem>[];
      json['cart_items'].forEach((v) {
        cartItems!.add(new CartItem.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['description'] = this.description;
    data['image'] = this.image;
    data['price'] = this.price;
    data['original_price'] = this.originalPrice;
    data['discount_percent'] = this.discountPercent;
    if (this.variants != null) {
      data['variants'] = this.variants!.map((v) => v.toJson()).toList();
    }
    if (this.options != null) {
      data['options'] = this.options!.map((v) => v.toJson()).toList();
    }
    if (this.reviews != null) {
      data['reviews'] = this.reviews!.map((v) => v.toJson()).toList();
    }
    if (this.images != null) {
      data['images'] = this.images!.map((v) => v.toJson()).toList();
    }
    if (this.cartItems != null) {
      data['cart_items'] = this.cartItems!.map((v) => v.toJson()).toList();
    }
    data['cart_status'] = this.cartStatus;
    data['average_rating'] = this.averageRating;
    data['ratings_count'] = this.ratingsCount;
    return data;
  }
}

class Variants {
  int? id;
  int? productId;
  String? title;
  double? price;
  int? position;
  String? inventoryPolicy;
  double? compareAtPrice;
  String? option1;
  String? option2;
  String? option3;
  String? createdAt;
  String? updatedAt;
  bool? taxable;
  String? barcode;
  String? fulfillmentService;
  int? grams;
  String? inventoryManagement;
  bool? requiresShipping;
  String? sku;
  int? weight;
  String? weightUnit;
  int? inventoryItemId;
  int? inventoryQuantity;
  int? oldInventoryQuantity;
  String? adminGraphqlApiId;
  int? imageId;
  String? image_url;

  Variants({
    this.id,
    this.productId,
    this.title,
    this.price,
    this.position,
    this.inventoryPolicy,
    this.compareAtPrice,
    this.option1,
    this.option2,
    this.option3,
    this.createdAt,
    this.updatedAt,
    this.taxable,
    this.barcode,
    this.fulfillmentService,
    this.grams,
    this.inventoryManagement,
    this.requiresShipping,
    this.sku,
    this.weight,
    this.weightUnit,
    this.inventoryItemId,
    this.inventoryQuantity,
    this.oldInventoryQuantity,
    this.adminGraphqlApiId,
    this.imageId,
    this.image_url,
  });

  Variants.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    productId = json['product_id'];
    title = json['title'];
    price = double.tryParse('${json['price']}');
    position = json['position'];
    inventoryPolicy = json['inventory_policy'];
    compareAtPrice = double.tryParse('${json['compare_at_price']}');
    option1 = json['option1'];
    option2 = json['option2'];
    option3 = json['option3'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    taxable = json['taxable'];
    barcode = json['barcode'];
    fulfillmentService = json['fulfillment_service'];
    grams = json['grams'];
    inventoryManagement = json['inventory_management'];
    requiresShipping = json['requires_shipping'];
    sku = json['sku'];
    weight = json['weight'];
    weightUnit = json['weight_unit'];
    inventoryItemId = json['inventory_item_id'];
    inventoryQuantity = json['inventory_quantity'];
    oldInventoryQuantity = json['old_inventory_quantity'];
    adminGraphqlApiId = json['admin_graphql_api_id'];
    imageId = json['image_id'];
    image_url = json['image_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['product_id'] = this.productId;
    data['title'] = this.title;
    data['price'] = this.price;
    data['position'] = this.position;
    data['inventory_policy'] = this.inventoryPolicy;
    data['compare_at_price'] = this.compareAtPrice;
    data['option1'] = this.option1;
    data['option2'] = this.option2;
    data['option3'] = this.option3;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['taxable'] = this.taxable;
    data['barcode'] = this.barcode;
    data['fulfillment_service'] = this.fulfillmentService;
    data['grams'] = this.grams;
    data['inventory_management'] = this.inventoryManagement;
    data['requires_shipping'] = this.requiresShipping;
    data['sku'] = this.sku;
    data['weight'] = this.weight;
    data['weight_unit'] = this.weightUnit;
    data['inventory_item_id'] = this.inventoryItemId;
    data['inventory_quantity'] = this.inventoryQuantity;
    data['old_inventory_quantity'] = this.oldInventoryQuantity;
    data['admin_graphql_api_id'] = this.adminGraphqlApiId;
    data['image_id'] = this.imageId;
    data['image_url'] = this.image_url;
    return data;
  }
}

class MedicineOptions {
  int? id;
  int? productId;
  String? name;
  int? position;
  List<String>? values;

  MedicineOptions(
      {this.id, this.productId, this.name, this.position, this.values});

  MedicineOptions.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    productId = json['product_id'];
    name = json['name'];
    position = json['position'];
    values = json['values'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['product_id'] = this.productId;
    data['name'] = this.name;
    data['position'] = this.position;
    data['values'] = this.values;
    return data;
  }
}

class MedicineReview {
  int? id;
  String? review;
  int? rate;
  int? orderId;
  int? productId;
  int? userId;
  String? createdAt;
  String? updatedAt;
  User? user;

  MedicineReview(
      {this.id,
      this.review,
      this.rate,
      this.orderId,
      this.productId,
      this.userId,
      this.createdAt,
      this.updatedAt,
      this.user});

  MedicineReview.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    review = json['review'];
    rate = json['rate'];
    orderId = json['order_id'];
    productId = json['product_id'];
    userId = json['user_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['review'] = this.review;
    data['rate'] = this.rate;
    data['appointment_id'] = this.orderId;
    data['doctor_id'] = this.productId;
    data['user_id'] = this.userId;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    if (this.user != null) {
      data['user'] = this.user!.toJson();
    }
    return data;
  }
}

class MedicineImage {
  int? id;
  String? alt;
  int? position;
  int? productId;
  String? createdAt;
  String? updatedAt;
  String? adminGraphqlApiId;
  int? width;
  int? height;
  String? src;
  List<int>? variantIds;

  MedicineImage(
      {this.id,
      this.alt,
      this.position,
      this.productId,
      this.createdAt,
      this.updatedAt,
      this.adminGraphqlApiId,
      this.width,
      this.height,
      this.src,
      this.variantIds});

  MedicineImage.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    alt = json['alt'];
    position = json['position'];
    productId = json['product_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    adminGraphqlApiId = json['admin_graphql_api_id'];
    width = json['width'];
    height = json['height'];
    src = json['src'];
    variantIds = json['variant_ids'].cast<int>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['alt'] = this.alt;
    data['position'] = this.position;
    data['product_id'] = this.productId;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['admin_graphql_api_id'] = this.adminGraphqlApiId;
    data['width'] = this.width;
    data['height'] = this.height;
    data['src'] = this.src;
    data['variant_ids'] = this.variantIds;
    return data;
  }
}
