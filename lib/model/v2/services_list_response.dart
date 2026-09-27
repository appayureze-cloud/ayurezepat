import 'package:doctro_patient/model/v2/therapy_home_response.dart';

class ServicesListResponse {
  bool? success;
  List<Services>? data;
  int? total;
  int? currentPage;
  int? lastPage;
  String? msg;

  ServicesListResponse(
      {this.success,
      this.data,
      this.total,
      this.currentPage,
      this.lastPage,
      this.msg});

  ServicesListResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = <Services>[];
      json['data'].forEach((v) {
        data!.add(new Services.fromJson(v));
      });
    }
    total = json['total'];
    currentPage = json['current_page'];
    lastPage = json['last_page'];
    msg = json['msg'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['total'] = this.total;
    data['current_page'] = this.currentPage;
    data['last_page'] = this.lastPage;
    data['msg'] = this.msg;
    return data;
  }
}
