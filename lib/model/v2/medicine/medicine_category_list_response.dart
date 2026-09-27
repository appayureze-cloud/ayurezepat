import 'package:doctro_patient/model/v2/doctor_list_response.dart' show Meta;
import 'package:doctro_patient/model/v2/medicine/medicine_home_response.dart';

class MedicineCategoryListResponse {
  bool? success;
  List<PopularCategories>? data;
  String? msg;
  Meta? meta;

  MedicineCategoryListResponse({this.success, this.data, this.msg, this.meta});

  MedicineCategoryListResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = <PopularCategories>[];
      json['data'].forEach((v) {
        data!.add(new PopularCategories.fromJson(v));
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
