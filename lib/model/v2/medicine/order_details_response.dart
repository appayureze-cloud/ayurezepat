import 'package:doctro_patient/model/v2/medicine/order_list_response.dart';

class OrderDetailsResposne {
  bool? success;
  Order? data;

  OrderDetailsResposne({this.success, this.data});

  OrderDetailsResposne.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? new Order.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Order {
  String? id;
  String? status;
  String? financialStatus;
  String? paymentMethod;
  String? placedAt;
  String? cancelledAt;
  String? cancelReason;
  String? cancelReasonNote;
  List<OrderedProduct>? products;
  ShippingAddress? billingAddress;
  ShippingAddress? shippingAddress;
  FareSplitup? fareSplitup;
  List<Tracking>? tracking;
  int? activeStep;

  Order({
    this.id,
    this.status,
    this.financialStatus,
    this.paymentMethod,
    this.placedAt,
    this.cancelledAt,
    this.cancelReason,
    this.cancelReasonNote,
    this.products,
    this.billingAddress,
    this.shippingAddress,
    this.fareSplitup,
    this.tracking,
    this.activeStep,
  });

  Order.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    status = json['status'];
    financialStatus = json['financial_status'];
    paymentMethod = json['payment_method'];
    placedAt = json['placed_at'];
    cancelledAt = json['cancelled_at'];
    cancelReason = json['cancel_reason'];
    cancelReasonNote = json['cancel_reason_note'];
    activeStep = json['active_step'];
    if (json['products'] != null) {
      products = <OrderedProduct>[];
      json['products'].forEach((v) {
        products!.add(new OrderedProduct.fromJson(v));
      });
    }
    billingAddress = json['billing_address'] != null
        ? ShippingAddress.fromJson(json['billing_address'])
        : null;
    shippingAddress = json['shipping_address'] != null
        ? ShippingAddress.fromJson(json['shipping_address'])
        : null;
    fareSplitup = json['fare_splitup'] != null
        ? new FareSplitup.fromJson(json['fare_splitup'])
        : null;
    if (json['tracking'] != null) {
      tracking = <Tracking>[];
      json['tracking'].forEach((v) {
        tracking!.add(new Tracking.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['status'] = this.status;
    data['financial_status'] = this.financialStatus;
    data['payment_method'] = this.paymentMethod;
    data['placed_at'] = this.placedAt;
    data['cancelled_at'] = this.cancelledAt;
    data['cancel_reason'] = this.cancelReason;
    data['cancel_reason_note'] = this.cancelReasonNote;
    data['active_step'] = this.activeStep;
    if (this.products != null) {
      data['products'] = this.products!.map((v) => v.toJson()).toList();
    }
    data['billing_address'] = this.billingAddress?.toJson();

    data['shipping_address'] = this.shippingAddress?.toJson();
    if (this.fareSplitup != null) {
      data['fare_splitup'] = this.fareSplitup!.toJson();
    }
    if (this.tracking != null) {
      data['tracking'] = this.tracking!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ShippingAddress {
  String? firstName;
  String? address1;
  String? phone;
  String? city;
  String? zip;
  String? province;
  String? country;
  String? lastName;
  String? address2;
  String? company;
  double? latitude;
  double? longitude;
  String? name;
  String? countryCode;
  String? provinceCode;

  ShippingAddress(
      {this.firstName,
      this.address1,
      this.phone,
      this.city,
      this.zip,
      this.province,
      this.country,
      this.lastName,
      this.address2,
      this.company,
      this.latitude,
      this.longitude,
      this.name,
      this.countryCode,
      this.provinceCode});

  ShippingAddress.fromJson(Map<String, dynamic> json) {
    firstName = json['first_name'];
    address1 = json['address1'];
    phone = json['phone'];
    city = json['city'];
    zip = json['zip'];
    province = json['province'];
    country = json['country'];
    lastName = json['last_name'];
    address2 = json['address2'];
    company = json['company'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    name = json['name'];
    countryCode = json['country_code'];
    provinceCode = json['province_code'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['first_name'] = this.firstName;
    data['address1'] = this.address1;
    data['phone'] = this.phone;
    data['city'] = this.city;
    data['zip'] = this.zip;
    data['province'] = this.province;
    data['country'] = this.country;
    data['last_name'] = this.lastName;
    data['address2'] = this.address2;
    data['company'] = this.company;
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    data['name'] = this.name;
    data['country_code'] = this.countryCode;
    data['province_code'] = this.provinceCode;
    return data;
  }
}

class FareSplitup {
  String? subtotalPrice;
  String? discounts;
  int? shipping;
  String? tax;
  String? total;
  String? currency;

  FareSplitup(
      {this.subtotalPrice,
      this.discounts,
      this.shipping,
      this.tax,
      this.total,
      this.currency});

  FareSplitup.fromJson(Map<String, dynamic> json) {
    subtotalPrice = json['subtotal_price'];
    discounts = json['discounts'];
    shipping = json['shipping'];
    tax = json['tax'];
    total = json['total'];
    currency = json['currency'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['subtotal_price'] = this.subtotalPrice;
    data['discounts'] = this.discounts;
    data['shipping'] = this.shipping;
    data['tax'] = this.tax;
    data['total'] = this.total;
    data['currency'] = this.currency;
    return data;
  }
}

class Tracking {
  String? step;
  String? status;
  String? happenedAt;

  Tracking({this.step, this.status, this.happenedAt});

  Tracking.fromJson(Map<String, dynamic> json) {
    step = json['step'];
    status = json['status'];
    happenedAt = json['happened_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['step'] = this.step;
    data['status'] = this.status;
    data['happened_at'] = this.happenedAt;
    return data;
  }
}
