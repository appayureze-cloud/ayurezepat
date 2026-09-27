import 'package:doctro_patient/model/v2/home_response.dart';

import 'doctor_list_response.dart';

class CategoryListResponse {
  bool? success;
  List<DoctorCategory>? data;
  Meta? meta;
  String? msg;

  CategoryListResponse(
      {this.success,
      this.data,
      this.meta,
      this.msg});

  CategoryListResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = <DoctorCategory>[];
      json['data'].forEach((v) {
        data!.add(new DoctorCategory.fromJson(v));
      });
    }
    meta = json["meta"] != null ? Meta.fromJson(json["meta"]) : null;
    msg = json['msg'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['msg'] = this.msg;
    data['meta'] = this.meta?.toJson();
    return data;
  }
}
