class AddressListResponse {
  bool? success;
  List<Address>? data;
  String? msg;

  AddressListResponse({this.success, this.data, this.msg});

  AddressListResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data!.add(new Address.fromJson(v));
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

class Address {
  int? id;
  String? address;
  String? lat;
  String? lang;
  String? label;

  Address({this.id, this.address, this.lat, this.lang, this.label});

  Address.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    address = json['address'];
    lat = json['lat'];
    lang = json['lang'];
    label = json['label'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['address'] = this.address;
    data['lat'] = this.lat;
    data['lang'] = this.lang;
    data['label'] = this.label;
    return data;
  }
}
