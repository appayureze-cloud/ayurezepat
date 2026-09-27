import 'package:doctro_patient/model/v2/appointment_details_response.dart';
import 'package:doctro_patient/model/v2/display_offer_model.dart';
import 'package:doctro_patient/model/v2/show_address_model.dart';
import 'package:doctro_patient/model/v2/therapy_home_response.dart';

class TherapyBookingDetailsResponse {
  bool? success;
  TherapyBookingDetails? data;
  String? msg;

  TherapyBookingDetailsResponse({this.success, this.data, this.msg});

  TherapyBookingDetailsResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null
        ? new TherapyBookingDetails.fromJson(json['data'])
        : null;
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

class TherapyBookingDetails {
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
  String? timming;
  AppointmentReview? reviewDetails;
  int? rate;
  int? review;
  Centers? center;
  Packages? package;
  Services? service;
  Coupon? discount;
  Address? booking_address;

  TherapyBookingDetails(
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
      this.paymentStatus,
      this.paymentType,
      this.bookingStatus,
      this.cancelReason,
      this.cancelBy,
      this.timming,
      this.reviewDetails,
      this.rate,
      this.review,
      this.center,
      this.package,
      this.service,
      this.discount,
      this.booking_address});

  TherapyBookingDetails.fromJson(Map<String, dynamic> json) {
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
    timming = json['timming'];
    if (json['review_details'] != null)
      reviewDetails = AppointmentReview.fromJson(json['review_details']);
    rate = json['rate'];
    review = json['review'];
    center =
        json['center'] != null ? new Centers.fromJson(json['center']) : null;
    package =
        json['package'] != null ? new Packages.fromJson(json['package']) : null;
    service =
        json['service'] != null ? new Services.fromJson(json['service']) : null;
    discount =
        json['discount'] != null ? new Coupon.fromJson(json['discount']) : null;
    booking_address = json['booking_address'] != null
        ? new Address.fromJson(json['booking_address'])
        : null;
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
    data['timming'] = this.timming;
    if (this.reviewDetails != null)
      data['review_details'] = this.reviewDetails!.toJson();
    data['rate'] = this.rate;
    data['review'] = this.review;
    if (this.center != null) {
      data['center'] = this.center!.toJson();
    }
    if (this.package != null) {
      data['package'] = this.package!.toJson();
    }
    if (this.service != null) {
      data['service'] = this.service!.toJson();
    }
    if (this.discount != null) {
      data['discount'] = this.discount!.toJson();
    }
    if (this.booking_address != null) {
      data['booking_address'] = this.booking_address!.toJson();
    }
    return data;
  }
}
