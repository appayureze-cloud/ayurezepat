import 'package:doctro_patient/model/v2/prescription_response.dart';

import 'home_response.dart';

class AppointmentDetailsResponse {
  bool? success;
  Appointment? data;
  String? msg;

  AppointmentDetailsResponse({this.success, this.data, this.msg});

  AppointmentDetailsResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? new Appointment.fromJson(json['data']) : null;
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

class Appointment {
  int? id;
  String? appointmentId;
  String? appointmentType;
  int? userId;
  int? doctorId;
  String? amount;
  String? paymentType;
  String? appointmentFor;
  String? patientName;
  int? age;
  List<String>? reportImage;
  String? drugEffect;
  String? patientAddress;
  String? phoneNo;
  String? phoneCode;
  String? date;
  String? time;
  int? duration;
  int? paymentStatus;
  String? appointmentStatus;
  String? illnessInformation;
  String? note;
  String? cancelReason;
  String? cancelBy;
  int? discountId;
  int? discountPrice;
  int? hospitalId;
  String? zoomUrl;
  int? isInsured;
  String? policyInsurerName;
  String? policyNumber;
  String? createdAt;
  String? updatedAt;
  Doctor? doctor;
  String? timming;
  int? rate;
  int? review;
  Hospital? hospital;
  AppointmentReview? reviewDetails;
  Prescription? prescription;

  Appointment({
    this.id,
    this.appointmentId,
    this.appointmentType,
    this.userId,
    this.doctorId,
    this.amount,
    this.paymentType,
    this.appointmentFor,
    this.patientName,
    this.age,
    this.reportImage,
    this.drugEffect,
    this.patientAddress,
    this.phoneNo,
    this.phoneCode,
    this.date,
    this.time,
    this.duration,
    this.paymentStatus,
    this.appointmentStatus,
    this.illnessInformation,
    this.note,
    this.cancelReason,
    this.cancelBy,
    this.discountId,
    this.discountPrice,
    this.hospitalId,
    this.zoomUrl,
    this.isInsured,
    this.policyInsurerName,
    this.policyNumber,
    this.createdAt,
    this.updatedAt,
    this.doctor,
    this.prescription,
    this.timming,
    this.rate,
    this.review,
    this.hospital,
    this.reviewDetails,
  });

  Appointment.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    appointmentId = json['appointment_id'];
    appointmentType = json['appointment_type'];
    userId = json['user_id'];
    doctorId = json['doctor_id'];
    amount = json['amount'];
    paymentType = json['payment_type'];
    appointmentFor = json['appointment_for'];
    patientName = json['patient_name'];
    age = json['age'];
    if (json['report_image'] != null) {
      reportImage = List<String>.from(json['report_image']);
    }
    drugEffect = json['drug_effect'];
    patientAddress = json['patient_address'];
    phoneNo = json['phone_no'];
    phoneCode = json['phone_code'];
    date = json['date'];
    time = json['time'];
    duration = json['duration'];
    paymentStatus = json['payment_status'];
    appointmentStatus = json['appointment_status'];
    illnessInformation = json['illness_information'];
    note = json['note'];
    cancelReason = json['cancel_reason'];
    cancelBy = json['cancel_by'];
    discountId = json['discount_id'];
    discountPrice = json['discount_price'];
    hospitalId = json['hospital_id'];
    zoomUrl = json['zoom_url'];
    isInsured = json['is_insured'];
    policyInsurerName = json['policy_insurer_name'];
    policyNumber = json['policy_number'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    doctor =
        json['doctor'] != null ? new Doctor.fromJson(json['doctor']) : null;
    timming = json['timming'];
    rate = json['rate'];
    review = json['review'];
    hospital = json['hospital'] != null
        ? new Hospital.fromJson(json['hospital'])
        : null;
    reviewDetails = json['review_details'] != null
        ? new AppointmentReview.fromJson(json['review_details'])
        : null;
    prescription = json['prescription'] != null
        ? new Prescription.fromJson(json['prescription'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['appointment_id'] = this.appointmentId;
    data['appointment_type'] = this.appointmentType;
    data['user_id'] = this.userId;
    data['doctor_id'] = this.doctorId;
    data['amount'] = this.amount;
    data['payment_type'] = this.paymentType;
    data['appointment_for'] = this.appointmentFor;
    data['patient_name'] = this.patientName;
    data['age'] = this.age;
    if (this.reportImage != null) {
      data['report_image'] = this.reportImage;
    }
    data['drug_effect'] = this.drugEffect;
    data['patient_address'] = this.patientAddress;
    data['phone_no'] = this.phoneNo;
    data['phone_code'] = this.phoneCode;
    data['date'] = this.date;
    data['time'] = this.time;
    data['duration'] = this.duration;
    data['payment_status'] = this.paymentStatus;
    data['appointment_status'] = this.appointmentStatus;
    data['illness_information'] = this.illnessInformation;
    data['note'] = this.note;
    data['cancel_reason'] = this.cancelReason;
    data['cancel_by'] = this.cancelBy;
    data['discount_id'] = this.discountId;
    data['discount_price'] = this.discountPrice;
    data['hospital_id'] = this.hospitalId;
    data['zoom_url'] = this.zoomUrl;
    data['is_insured'] = this.isInsured;
    data['policy_insurer_name'] = this.policyInsurerName;
    data['policy_number'] = this.policyNumber;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    if (this.doctor != null) {
      data['doctor'] = this.doctor!.toJson();
    }
    data['timming'] = this.timming;
    data['rate'] = this.rate;
    data['review'] = this.review;
    if (this.hospital != null) {
      data['hospital'] = this.hospital!.toJson();
    }
    if (this.reviewDetails != null) {
      data['review_details'] = this.reviewDetails!.toJson();
    }
    if (this.prescription != null) {
      data['prescription'] = this.prescription!.toJson();
    }
    return data;
  }
}

class AppointmentReview {
  int? id;
  String? review;
  int? rate;
  int? appointmentId;
  int? doctorId;
  int? userId;
  String? createdAt;
  String? updatedAt;

  AppointmentReview(
      {this.id,
      this.review,
      this.rate,
      this.appointmentId,
      this.doctorId,
      this.userId,
      this.createdAt,
      this.updatedAt});

  AppointmentReview.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    review = json['review'];
    rate = json['rate'];
    appointmentId = json['appointment_id'];
    doctorId = json['doctor_id'];
    userId = json['user_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['review'] = this.review;
    data['rate'] = this.rate;
    data['appointment_id'] = this.appointmentId;
    data['doctor_id'] = this.doctorId;
    data['user_id'] = this.userId;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
