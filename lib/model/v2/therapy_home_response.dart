import 'package:doctro_patient/model/v2/home_response.dart';

import 'blog.dart';

class TherapyHomeResponse {
  bool? success;
  Data? data;

  TherapyHomeResponse({this.success, this.data});

  TherapyHomeResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
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

class Data {
  List<Banner>? banner;
  List<Services>? services;
  List<Packages>? packages;
  List<Blogs>? blogs;
  List<Centers>? centers;

  Data({this.banner, this.services, this.packages, this.blogs, this.centers});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['banner'] != null) {
      banner = <Banner>[];
      json['banner'].forEach((v) {
        banner!.add(new Banner.fromJson(v));
      });
    }
    if (json['services'] != null) {
      services = <Services>[];
      json['services'].forEach((v) {
        services!.add(new Services.fromJson(v));
      });
    }
    if (json['packages'] != null) {
      packages = <Packages>[];
      json['packages'].forEach((v) {
        packages!.add(new Packages.fromJson(v));
      });
    }
    if (json['blogs'] != null) {
      blogs = <Blogs>[];
      json['blogs'].forEach((v) {
        blogs!.add(new Blogs.fromJson(v));
      });
    }
    if (json['centers'] != null) {
      centers = <Centers>[];
      json['centers'].forEach((v) {
        centers!.add(new Centers.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.banner != null) {
      data['banner'] = this.banner!.map((v) => v.toJson()).toList();
    }
    if (this.services != null) {
      data['services'] = this.services!.map((v) => v.toJson()).toList();
    }
    if (this.packages != null) {
      data['packages'] = this.packages!.map((v) => v.toJson()).toList();
    }
    if (this.blogs != null) {
      data['blogs'] = this.blogs!.map((v) => v.toJson()).toList();
    }
    if (this.centers != null) {
      data['centers'] = this.centers!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Services {
  int? id;
  int? therapy_center_id;
  int? therapy_services_id;
  int? status;
  String? fees;
  String? duration;
  String? name;
  String? description;
  String? icon;

  Services(
      {this.id,
      this.status,
      this.fees,
      this.duration,
      this.name,
      this.description,
      this.therapy_services_id,
      this.therapy_center_id,
      this.icon});

  Services.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    status = json['status'];
    fees = json['fees'];
    duration = json['duration'];
    name = json['name'];
    description = json['description'];
    icon = json['icon'];
    therapy_services_id = json['therapy_services_id'];
    therapy_center_id = json['therapy_center_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['status'] = this.status;
    data['fees'] = this.fees;
    data['duration'] = this.duration;
    data['name'] = this.name;
    data['description'] = this.description;
    data['icon'] = this.icon;
    data['therapy_center_id'] = this.therapy_center_id;
    data['therapy_services_id'] = this.therapy_services_id;
    return data;
  }
}

class Packages {
  int? id;
  int? therapyCenterId;
  String? packageName;
  String? fees;
  int? status;
  List<Services>? services;
  Centers? center;
  int? duration;

  Packages(
      {this.id,
      this.therapyCenterId,
      this.packageName,
      this.fees,
      this.status,
      this.services,
      this.center,
      this.duration});

  Packages.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    therapyCenterId = json['therapy_center_id'];
    packageName = json['package_name'];
    fees = json['fees'];
    status = json['status'];
    duration = json['duration'];
    if (json['services'] != null) {
      services = <Services>[];
      json['services'].forEach((v) {
        services!.add(new Services.fromJson(v));
      });
    }
    if (json['center'] != null) {
      center = Centers.fromJson(json['center']);
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['therapy_center_id'] = this.therapyCenterId;
    data['package_name'] = this.packageName;
    data['fees'] = this.fees;
    data['status'] = this.status;
    data['duration'] = this.duration;
    if (this.services != null) {
      data['services'] = this.services!.map((v) => v.toJson()).toList();
    }
    if (this.center != null) {
      data['center'] = this.center!.toJson();
    }
    return data;
  }
}

class Centers {
  int? id;
  String? name;
  String? phone;
  String? startTime;
  String? endTime;
  String? address;
  String? lat;
  String? lng;
  int? status;
  int? rate;
  int? review;
  List<String>? gallery;

  Centers(
      {this.id,
      this.name,
      this.phone,
      this.startTime,
      this.endTime,
      this.address,
      this.lat,
      this.lng,
      this.status,
      this.rate,
      this.review,
      this.gallery});

  Centers.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    phone = json['phone'];
    startTime = json['start_time'];
    endTime = json['end_time'];
    address = json['address'];
    lat = json['lat'];
    lng = json['lng'];
    status = json['status'];
    rate = json['rate'];
    review = json['review'];
    gallery = json['gallery'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['phone'] = this.phone;
    data['start_time'] = this.startTime;
    data['end_time'] = this.endTime;
    data['address'] = this.address;
    data['lat'] = this.lat;
    data['lng'] = this.lng;
    data['status'] = this.status;
    data['rate'] = this.rate;
    data['review'] = this.review;
    data['gallery'] = this.gallery;
    return data;
  }
}
