import 'package:doctro_patient/model/v2/home_response.dart';

class DoctorListResponse {
  bool? success;
  List<Doctor>? data;
  String? msg;
  Meta? meta;

  DoctorListResponse({this.success, this.data, this.msg, this.meta});

  DoctorListResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = <Doctor>[];
      json['data'].forEach((v) {
        data!.add(new Doctor.fromJson(v));
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

class Meta {
  int? total;
  int? page;
  int? perPage;
  int? totalPages;

  Meta({this.total, this.page, this.perPage, this.totalPages});

  Meta.fromJson(Map<String, dynamic> json) {
    total = json['total'];
    page = json['page'];
    perPage = json['per_page'];
    totalPages = json['total_pages'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['total'] = this.total;
    data['page'] = this.page;
    data['per_page'] = this.perPage;
    data['total_pages'] = this.totalPages;
    return data;
  }
}
