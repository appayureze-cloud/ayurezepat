class CouponsResponse {
  bool? success;
  List<Coupon>? data;
  String? msg;

  CouponsResponse({this.success, this.data, this.msg});

  CouponsResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data!.add(new Coupon.fromJson(v));
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

class Coupon {
  int? id;
  String? name;
  String? image;
  String? offerCode;
  double? discount;
  int? isFlat;
  String? discountType;
  double? flatDiscount;
  double? minDiscount;
  String? fullImage;

  Coupon(
      {this.id,
      this.name,
      this.image,
      this.offerCode,
      this.discount,
      this.isFlat,
      this.discountType,
      this.minDiscount,
      this.flatDiscount,
      this.fullImage});

  Coupon.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    image = json['image'];
    offerCode = json['offer_code'];
    minDiscount = double.tryParse('${json['min_discount']}');
    discount = double.tryParse('${json['discount']}');
    isFlat = json['is_flat'];
    discountType = json['discount_type'];
    flatDiscount = double.tryParse('${json['flatDiscount']}');
    fullImage = json['fullImage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['image'] = this.image;
    data['offer_code'] = this.offerCode;
    data['discount'] = this.discount;
    data['min_discount'] = this.minDiscount;
    data['is_flat'] = this.isFlat;
    data['discount_type'] = this.discountType;
    data['flatDiscount'] = this.flatDiscount;
    data['fullImage'] = this.fullImage;
    return data;
  }
}
