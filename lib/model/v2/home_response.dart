import 'dart:convert';

import 'blog.dart';

class HomeResponse {
  bool? success;
  Data? data;

  HomeResponse({this.success, this.data});

  HomeResponse.fromJson(Map<String, dynamic> json) {
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
  List<Doctor>? doctors;
  Settings? settings;
  List<DoctorCategory>? categories;
  List<Blogs>? blogs;

  Data({this.banner, this.doctors, this.settings, this.categories, this.blogs});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['banner'] != null) {
      banner = <Banner>[];
      json['banner'].forEach((v) {
        banner!.add(new Banner.fromJson(v));
      });
    }
    if (json['doctors'] != null) {
      doctors = <Doctor>[];
      json['doctors'].forEach((v) {
        doctors!.add(new Doctor.fromJson(v));
      });
    }
    settings = json['settings'] != null
        ? new Settings.fromJson(json['settings'])
        : null;
    if (json['categories'] != null) {
      categories = <DoctorCategory>[];
      json['categories'].forEach((v) {
        categories!.add(new DoctorCategory.fromJson(v));
      });
    }
    if (json['blogs'] != null) {
      blogs = <Blogs>[];
      json['blogs'].forEach((v) {
        blogs!.add(new Blogs.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.banner != null) {
      data['banner'] = this.banner!.map((v) => v.toJson()).toList();
    }
    if (this.doctors != null) {
      data['doctors'] = this.doctors!.map((v) => v.toJson()).toList();
    }
    if (this.settings != null) {
      data['settings'] = this.settings!.toJson();
    }
    if (this.categories != null) {
      data['categories'] = this.categories!.map((v) => v.toJson()).toList();
    }
    if (this.blogs != null) {
      data['blogs'] = this.blogs!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Banner {
  int? id;
  String? name;
  String? description;
  String? image;
  String? link;
  int? status;
  String? createdAt;
  String? updatedAt;
  String? fullImage;

  Banner(
      {this.id,
      this.name,
      this.description,
      this.image,
      this.link,
      this.status,
      this.createdAt,
      this.updatedAt,
      this.fullImage});

  Banner.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    description = json['description'];
    image = json['image'];
    link = json['link'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    fullImage = json['fullImage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['description'] = this.description;
    data['image'] = this.image;
    data['link'] = this.link;
    data['status'] = this.status;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['fullImage'] = this.fullImage;
    return data;
  }
}

class Doctor {
  int? id;
  String? name;
  String? image;
  String? hospitalId;
  String? since;
  String? timeslot;
  int? customTimeslot;
  List<Education>? education;
  String? appointmentFees;
  String? videoAppointmentFees;
  List<Hospital>? hospital;
  String? fullImage;
  int? rate;
  int? review;
  String? experience;
  Treatment? treatment;
  Expertise? expertise;
  DoctorCategory? category;
  double? nearestDistance;

  Doctor(
      {this.id,
      this.name,
      this.image,
      this.hospitalId,
      this.since,
      this.timeslot,
      this.customTimeslot,
      this.education,
      this.appointmentFees,
      this.videoAppointmentFees,
      this.hospital,
      this.fullImage,
      this.rate,
      this.review,
      this.treatment,
      this.expertise,
      this.experience,
      this.nearestDistance,
      this.category});

  Doctor.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    image = json['image'];
    hospitalId = json['hospital_id'];
    since = json['since'];
    timeslot = json['timeslot'];
    customTimeslot = json['custom_timeslot'];
    if (json['education'] is String && jsonDecode(json['education']) is List) {
      education = List<Map<String, dynamic>>.from(jsonDecode(json['education']))
          .map((e) => Education.fromJson(e))
          .toList();
    }
    appointmentFees = json['appointment_fees'];
    videoAppointmentFees = json['video_appointment_fees'];
    if (json['hospital'] != null) {
      hospital = <Hospital>[];
      json['hospital'].forEach((v) {
        hospital!.add(new Hospital.fromJson(v));
      });
    }
    fullImage = json['fullImage'];
    rate = json['rate'];
    review = json['review'];
    experience = json['experience'];
    if (json['treatment'] != null)
      treatment = Treatment.fromJson(json['treatment']);
    if (json['expertise'] != null)
      expertise = Expertise.fromJson(json['expertise']);
    if (json['category'] != null)
      category = DoctorCategory.fromJson(json['category']);
    nearestDistance = json['nearest_distance'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['image'] = this.image;
    data['hospital_id'] = this.hospitalId;
    data['since'] = this.since;
    data['timeslot'] = this.timeslot;
    data['custom_timeslot'] = this.customTimeslot;
    if (this.education is List<Education>)
      data['education'] = jsonEncode(this.education!.map((e) => e.toJson()));
    data['appointment_fees'] = this.appointmentFees;
    data['video_appointment_fees'] = this.videoAppointmentFees;
    if (this.hospital != null) {
      data['hospital'] = this.hospital!.map((v) => v.toJson()).toList();
    }
    data['fullImage'] = this.fullImage;
    data['rate'] = this.rate;
    data['review'] = this.review;
    data['experience'] = this.experience;
    if (this.treatment != null) data['treatment'] = this.treatment!.toJson();
    if (this.expertise != null) data['expertise'] = this.expertise!.toJson();
    if (this.category != null) data['category'] = this.category!.toJson();
    data['nearest_distance'] = this.nearestDistance;
    return data;
  }
}

class Education {
  String? degree;
  String? college;
  String? year;

  Education({this.degree, this.college, this.year});

  Education.fromJson(Map<String, dynamic> json) {
    degree = json['degree'];
    college = json['college'];
    year = json['year'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['degree'] = this.degree;
    data['college'] = this.college;
    data['year'] = this.year;
    return data;
  }
}

class Hospital {
  int? id;
  double? hospitalDistance;
  String? hospitalName;
  String? address;
  String? phone;
  String? lat;
  String? lng;

  Hospital({
    this.hospitalDistance,
    this.hospitalName,
    this.id,
    this.address,
    this.phone,
    this.lat,
    this.lng,
  });

  Hospital.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    hospitalDistance = double.tryParse('${json['hospital_distance']}');
    hospitalName = json['name'];
    phone = json['phone'];
    address = json['address'];
    lat = json['lat'];
    lng = json['lng'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['hospital_distance'] = this.hospitalDistance;
    data['name'] = this.hospitalName;
    data['address'] = this.address;
    data['phone'] = this.phone;
    data['lat'] = this.lat;
    data['lng'] = this.lng;
    return data;
  }
}

class Settings {
  int? cod;
  String? doctorAppId;
  int? paypal;
  int? stripe;
  int? razor;
  int? flutterwave;
  int? paystack;
  String? stripePublicKey;
  String? stripeSecretKey;
  String? razorKey;
  String? flutterwaveEncryptionKey;
  String? patientAppId;
  String? playstore;
  String? appstore;
  String? privacyPolicy;
  String? aboutUs;
  String? agoraAppId;
  String? agoraAppCertificate;
  String? cancelReason;
  String? flutterwaveKey;
  String? paystackPublicKey;
  String? currencySymbol;
  String? currencyCode;
  int? isLiveKey;
  String? paypalClientId;
  String? paypalSecretKey;
  String? home_chatbot;
  String? medical_tourism;

  Settings({
    this.cod,
    this.doctorAppId,
    this.paypal,
    this.stripe,
    this.razor,
    this.flutterwave,
    this.paystack,
    this.stripePublicKey,
    this.stripeSecretKey,
    this.razorKey,
    this.flutterwaveEncryptionKey,
    this.patientAppId,
    this.playstore,
    this.appstore,
    this.privacyPolicy,
    this.aboutUs,
    this.agoraAppId,
    this.agoraAppCertificate,
    this.cancelReason,
    this.flutterwaveKey,
    this.paystackPublicKey,
    this.currencySymbol,
    this.currencyCode,
    this.isLiveKey,
    this.paypalClientId,
    this.paypalSecretKey,
    this.medical_tourism,
    this.home_chatbot,
  });

  Settings.fromJson(Map<String, dynamic> json) {
    cod = json['cod'];
    doctorAppId = json['doctor_app_id'];
    paypal = json['paypal'];
    stripe = json['stripe'];
    razor = json['razor'];
    flutterwave = json['flutterwave'];
    paystack = json['paystack'];
    stripePublicKey = json['stripe_public_key'];
    stripeSecretKey = json['stripe_secret_key'];
    razorKey = json['razor_key'];
    flutterwaveEncryptionKey = json['flutterwave_encryption_key'];
    patientAppId = json['patient_app_id'];
    playstore = json['playstore'];
    appstore = json['appstore'];
    privacyPolicy = json['privacy_policy'];
    aboutUs = json['about_us'];
    agoraAppId = json['agora_app_id'];
    agoraAppCertificate = json['agora_app_certificate'];
    cancelReason = json['cancel_reason'];
    flutterwaveKey = json['flutterwave_key'];
    paystackPublicKey = json['paystack_public_key'];
    currencySymbol = json['currency_symbol'];
    currencyCode = json['currency_code'];
    isLiveKey = json['isLiveKey'];
    paypalClientId = json['paypal_client_id'];
    paypalSecretKey = json['paypal_secret_key'];
    medical_tourism = json['medical_tourism'];
    home_chatbot = json['home_chatbot'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['cod'] = this.cod;
    data['doctor_app_id'] = this.doctorAppId;
    data['paypal'] = this.paypal;
    data['stripe'] = this.stripe;
    data['razor'] = this.razor;
    data['flutterwave'] = this.flutterwave;
    data['paystack'] = this.paystack;
    data['stripe_public_key'] = this.stripePublicKey;
    data['stripe_secret_key'] = this.stripeSecretKey;
    data['razor_key'] = this.razorKey;
    data['flutterwave_encryption_key'] = this.flutterwaveEncryptionKey;
    data['patient_app_id'] = this.patientAppId;
    data['playstore'] = this.playstore;
    data['appstore'] = this.appstore;
    data['privacy_policy'] = this.privacyPolicy;
    data['about_us'] = this.aboutUs;
    data['agora_app_id'] = this.agoraAppId;
    data['agora_app_certificate'] = this.agoraAppCertificate;
    data['cancel_reason'] = this.cancelReason;
    data['flutterwave_key'] = this.flutterwaveKey;
    data['paystack_public_key'] = this.paystackPublicKey;
    data['currency_symbol'] = this.currencySymbol;
    data['currency_code'] = this.currencyCode;
    data['isLiveKey'] = this.isLiveKey;
    data['paypal_client_id'] = this.paypalClientId;
    data['paypal_secret_key'] = this.paypalSecretKey;
    data['medical_tourism'] = this.medical_tourism;
    data['home_chatbot'] = this.home_chatbot;
    return data;
  }
}

class DoctorCategory {
  int? id;
  String? name;
  String? fullImage;

  DoctorCategory({this.id, this.name, this.fullImage});

  DoctorCategory.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    fullImage = json['fullImage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['fullImage'] = this.fullImage;
    return data;
  }
}

class Treatment {
  int? id;
  String? name;
  String? fullImage;

  Treatment({this.id, this.name, this.fullImage});

  Treatment.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    fullImage = json['fullImage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['fullImage'] = this.fullImage;
    return data;
  }
}

class Expertise {
  int? id;
  String? name;

  Expertise({this.id, this.name});

  Expertise.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    return data;
  }
}
