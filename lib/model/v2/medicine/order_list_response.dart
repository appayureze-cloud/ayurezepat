import 'package:doctro_patient/model/v2/doctor_list_response.dart' show Meta;

class OrderListResponse {
  bool? success;
  List<OrderListItem>? data;
  String? msg;
  Meta? meta;

  OrderListResponse({this.success, this.data, this.msg, this.meta});

  OrderListResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = <OrderListItem>[];
      json['data'].forEach((v) {
        data!.add(new OrderListItem.fromJson(v));
      });
    }
    msg = json['msg'];
    meta = json['meta'] != null ? new Meta.fromJson(json['meta']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['msg'] = this.msg;
    if (this.meta != null) {
      data['meta'] = this.meta!.toJson();
    }
    return data;
  }
}

class OrderListItem {
  int? id;
  int? orderNumber;
  String? createdAt;
  double? totalPrice;
  String? financialStatus;
  String? fulfillmentStatus;
  String? status;
  List<OrderedProduct>? products;
  int? totalItemsOrdered;

  OrderListItem({
    this.id,
    this.orderNumber,
    this.createdAt,
    this.totalPrice,
    this.financialStatus,
    this.fulfillmentStatus,
    this.status,
    this.products = const [],
    this.totalItemsOrdered = 0,
  });

  OrderListItem.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    orderNumber = json['order_number'];
    createdAt = json['created_at'];
    totalPrice = double.tryParse('${json['total_price']}');
    financialStatus = json['financial_status'];
    fulfillmentStatus = json['fulfillment_status'];
    status = json['status'];
    products = [];
    products = (json['products'] as List<dynamic>?)
            ?.map((e) => OrderedProduct.fromJson(e))
            .toList() ??
        [];
    totalItemsOrdered = json['total_items_ordered'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['order_number'] = this.orderNumber;
    data['created_at'] = this.createdAt;
    data['total_price'] = this.totalPrice;
    data['financial_status'] = this.financialStatus;
    data['fulfillment_status'] = this.fulfillmentStatus;
    data['status'] = this.status;
    data['products'] = this.products?.map((e) => e.toJson()).toList() ?? [];
    data['total_items_ordered'] = this.totalItemsOrdered;
    return data;
  }
}

class OrderedProduct {
  int? productId;
  String? title;
  String? variantTitle;
  int? quantity;
  String? price;
  String? image;

  OrderedProduct({
    this.price,
    this.productId,
    this.quantity,
    this.image,
    this.title,
    this.variantTitle,
  });

  OrderedProduct.fromJson(Map<String, dynamic> json) {
    price = json['price'];
    productId = json['product_id'];
    quantity = json['quantity'];
    title = json['title'];
    variantTitle = json['variant_title'];
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['price'] = this.price;
    data['product_id'] = this.productId;
    data['quantity'] = this.quantity;
    data['title'] = this.title;
    data['variant_title'] = this.variantTitle;
    data['image'] = this.image;
    return data;
  }
}
