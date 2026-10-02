import 'package:doctro_patient/model/v2/therapy_home_response.dart';

import 'doctor_list_response.dart';

class CentersListResponse {
  bool? success;
  List<Centers>? data;
  String? msg;
  Meta? meta;

  CentersListResponse({this.success, this.data, this.msg, this.meta});

  CentersListResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = <Centers>[];
      json['data'].forEach((v) {
        data!.add(new Centers.fromJson(v));
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
