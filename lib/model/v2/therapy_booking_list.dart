import 'package:doctro_patient/model/v2/therapy_home_response.dart';

class TherapyBookingListResponse {
  bool? success;
  Data? data;
  String? msg;

  TherapyBookingListResponse({this.success, this.data, this.msg});

  TherapyBookingListResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
    msg = json['msg'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['msg'] = this.msg;
    return data;
  }
}

class Data {
  List<TherapyBooking>? upcoming;
  List<TherapyBooking>? cancelled;
  List<TherapyBooking>? completed;

  Data({this.upcoming, this.cancelled, this.completed});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['upcoming'] != null) {
      upcoming = <TherapyBooking>[];
      json['upcoming'].forEach((v) {
        upcoming!.add(new TherapyBooking.fromJson(v));
      });
    }
    if (json['cancelled'] != null) {
      cancelled = <TherapyBooking>[];
      json['cancelled'].forEach((v) {
        cancelled!.add(new TherapyBooking.fromJson(v));
      });
    }
    if (json['completed'] != null) {
      completed = <TherapyBooking>[];
      json['completed'].forEach((v) {
        completed!.add(new TherapyBooking.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.upcoming != null) {
      data['upcoming'] = this.upcoming!.map((v) => v.toJson()).toList();
    }
    if (this.cancelled != null) {
      data['cancelled'] = this.cancelled!.map((v) => v.toJson()).toList();
    }
    if (this.completed != null) {
      data['completed'] = this.completed!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class TherapyBooking {
  int? id;
  String? therapyBookingId;
  String? type;
  int? packageId;
  int? serviceId;
  int? userId;
  String? bookingFor;
  double? amount;
  int? discountId;
  double? discountPrice;
  String? name;
  int? age;
  int? address;
  String? phoneNo;
  String? phoneCode;
  String? date;
  String? time;
  int? duration;
  int? paymentStatus;
  String? paymentType;
  String? bookingStatus;
  String? cancelReason;
  String? cancelBy;
  String? createdAt;
  String? updatedAt;
  int? rate;
  int? review;
  Packages? package;
  Services? service;
  Centers? center;

  TherapyBooking(
      {this.id,
      this.therapyBookingId,
      this.type,
      this.packageId,
      this.serviceId,
      this.userId,
      this.bookingFor,
      this.amount,
      this.discountId,
      this.discountPrice,
      this.name,
      this.age,
      this.address,
      this.phoneNo,
      this.phoneCode,
      this.date,
      this.time,
      this.duration,
      this.center,
      this.paymentStatus,
      this.paymentType,
      this.bookingStatus,
      this.cancelReason,
      this.cancelBy,
      this.createdAt,
      this.updatedAt,
      this.rate,
      this.review,
      this.package,
      this.service});

  TherapyBooking.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    therapyBookingId = json['therapy_booking_id'];
    type = json['type'];
    packageId = json['package_id'];
    serviceId = json['service_id'];
    userId = json['user_id'];
    bookingFor = json['booking_for'];
    amount = double.tryParse('${json['amount']}');
    discountId = json['discount_id'];
    discountPrice = double.tryParse('${json['discount_price']}');
    name = json['name'];
    age = json['age'];
    address = json['address'];
    phoneNo = json['phone_no'];
    phoneCode = json['phone_code'];
    date = json['date'];
    time = json['time'];
    duration = json['duration'];
    paymentStatus = json['payment_status'];
    paymentType = json['payment_type'];
    bookingStatus = json['booking_status'];
    cancelReason = json['cancel_reason'];
    cancelBy = json['cancel_by'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    rate = json['rate'];
    review = json['review'];
    package =
        json['package'] != null ? new Packages.fromJson(json['package']) : null;
    service =
        json['service'] != null ? new Services.fromJson(json['service']) : null;
    center =
        json['center'] != null ? new Centers.fromJson(json['center']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['therapy_booking_id'] = this.therapyBookingId;
    data['type'] = this.type;
    data['package_id'] = this.packageId;
    data['service_id'] = this.serviceId;
    data['user_id'] = this.userId;
    data['booking_for'] = this.bookingFor;
    data['amount'] = this.amount;
    data['discount_id'] = this.discountId;
    data['discount_price'] = this.discountPrice;
    data['name'] = this.name;
    data['age'] = this.age;
    data['address'] = this.address;
    data['phone_no'] = this.phoneNo;
    data['phone_code'] = this.phoneCode;
    data['date'] = this.date;
    data['time'] = this.time;
    data['duration'] = this.duration;
    data['payment_status'] = this.paymentStatus;
    data['payment_type'] = this.paymentType;
    data['booking_status'] = this.bookingStatus;
    data['cancel_reason'] = this.cancelReason;
    data['cancel_by'] = this.cancelBy;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['rate'] = this.rate;
    data['review'] = this.review;
    if (this.service != null) {
      data['service'] = this.service!.toJson();
    }
    if (this.center != null) {
      data['center'] = this.center!.toJson();
    }
    if (this.package != null) {
      data['package'] = this.package!.toJson();
    }
    return data;
  }
}
