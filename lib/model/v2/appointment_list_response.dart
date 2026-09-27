import 'package:doctro_patient/model/v2/home_response.dart';

class AppointmentListResponse {
  bool? success;
  Data? data;
  String? msg;

  AppointmentListResponse({this.success, this.data, this.msg});

  AppointmentListResponse.fromJson(Map<String, dynamic> json) {
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
  List<AppointmentListItemModal>? upcomingAppointment;
  List<AppointmentListItemModal>? pendingAppointment;
  List<AppointmentListItemModal>? pastAppointment;

  Data(
      {this.upcomingAppointment,
      this.pendingAppointment,
      this.pastAppointment});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['upcoming_appointment'] != null) {
      upcomingAppointment = <AppointmentListItemModal>[];
      json['upcoming_appointment'].forEach((v) {
        upcomingAppointment!.add(new AppointmentListItemModal.fromJson(v));
      });
    }
    if (json['pending_appointment'] != null) {
      pendingAppointment = <AppointmentListItemModal>[];
      json['pending_appointment'].forEach((v) {
        pendingAppointment!.add(new AppointmentListItemModal.fromJson(v));
      });
    }
    if (json['past_appointment'] != null) {
      pastAppointment = <AppointmentListItemModal>[];
      json['past_appointment'].forEach((v) {
        pastAppointment!.add(new AppointmentListItemModal.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.upcomingAppointment != null) {
      data['upcoming_appointment'] =
          this.upcomingAppointment!.map((v) => v.toJson()).toList();
    }
    if (this.pendingAppointment != null) {
      data['pending_appointment'] =
          this.pendingAppointment!.map((v) => v.toJson()).toList();
    }
    if (this.pastAppointment != null) {
      data['past_appointment'] =
          this.pastAppointment!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class AppointmentListItemModal {
  int? id;
  String? date;
  String? time;
  int? duration;
  String? appointmentStatus;
  String? patientName;
  int? doctorId;
  String? appointmentId;
  int? hospitalId;
  String? appointmentType;
  Doctor? doctor;
  bool? prescription;
  int? rate;
  int? review;
  Hospital? hospital;

  AppointmentListItemModal(
      {this.id,
      this.date,
      this.time,
      this.duration,
      this.appointmentStatus,
      this.patientName,
      this.doctorId,
      this.appointmentId,
      this.hospitalId,
      this.appointmentType,
      this.doctor,
      this.prescription,
      this.rate,
      this.review,
      this.hospital});

  AppointmentListItemModal.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    date = json['date'];
    time = json['time'];
    duration = json['duration'];
    appointmentStatus = json['appointment_status'];
    patientName = json['patient_name'];
    doctorId = json['doctor_id'];
    appointmentId = json['appointment_id'];
    hospitalId = json['hospital_id'];
    appointmentType = json['appointment_type'];
    doctor =
        json['doctor'] != null ? new Doctor.fromJson(json['doctor']) : null;
    prescription = json['prescription'];
    rate = json['rate'];
    review = json['review'];
    hospital = json['hospital'] != null
        ? new Hospital.fromJson(json['hospital'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['date'] = this.date;
    data['time'] = this.time;
    data['duration'] = this.duration;
    data['appointment_status'] = this.appointmentStatus;
    data['patient_name'] = this.patientName;
    data['doctor_id'] = this.doctorId;
    data['appointment_id'] = this.appointmentId;
    data['hospital_id'] = this.hospitalId;
    data['appointment_type'] = this.appointmentType;
    if (this.doctor != null) {
      data['doctor'] = this.doctor!.toJson();
    }
    data['prescription'] = this.prescription;
    data['rate'] = this.rate;
    data['review'] = this.review;
    if (this.hospital != null) {
      data['hospital'] = this.hospital!.toJson();
    }
    return data;
  }
}
