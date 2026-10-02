import 'package:doctro_patient/features/prescriptions/domain/entities/prescription_item.dart';
import 'package:doctro_patient/model/v2/home_response.dart';

class PrescriptionResponse {
  bool? success;
  Data? data;
  String? msg;

  PrescriptionResponse({this.success, this.data, this.msg});

  PrescriptionResponse.fromJson(Map<String, dynamic> json) {
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
  int? id;
  Doctor? doctor;
  Prescription? prescription;
  int? rate;
  int? review;

  Data({this.id, this.doctor, this.prescription, this.rate, this.review});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    // `doctor` is typed as `Doctor?` but this used to assign the raw JSON
    // map straight into it, which throws a runtime TypeError the first
    // time a response actually includes a doctor object.
    doctor = json['doctor'] != null ? Doctor.fromJson(json['doctor']) : null;
    prescription = json['prescription'] != null
        ? new Prescription.fromJson(json['prescription'])
        : null;
    rate = json['rate'];
    review = json['review'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['doctor'] = this.doctor;
    if (this.prescription != null) {
      data['prescription'] = this.prescription!.toJson();
    }
    data['rate'] = this.rate;
    data['review'] = this.review;
    return data;
  }
}

class Prescription {
  int? id;
  int? appointmentId;
  int? doctorId;
  int? userId;
  String? medicines;
  String? pdf;
  String? createdAt;
  String? updatedAt;
  String? pdfPath;

  /// Structured line items, per docs/backend/prescriptions.md. Null/empty
  /// until the backend ships this - the PDF (`pdf`/`pdfPath`) remains the
  /// source of truth until then.
  List<PrescriptionItem>? items;

  /// Free-text treatment/therapy recommendation from the doctor, if any.
  /// Phase 3 prefills the therapy booking flow from this.
  String? treatmentRecommendation;

  Prescription(
      {this.id,
      this.appointmentId,
      this.doctorId,
      this.userId,
      this.medicines,
      this.pdf,
      this.createdAt,
      this.updatedAt,
      this.pdfPath,
      this.items,
      this.treatmentRecommendation});

  Prescription.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    appointmentId = json['appointment_id'];
    doctorId = json['doctor_id'];
    userId = json['user_id'];
    medicines = json['medicines'];
    pdf = json['pdf'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    pdfPath = json['pdfPath'];
    if (json['items'] != null) {
      items = (json['items'] as List)
          .map((e) => PrescriptionItem.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    treatmentRecommendation = json['treatment_recommendation'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['appointment_id'] = this.appointmentId;
    data['doctor_id'] = this.doctorId;
    data['user_id'] = this.userId;
    data['medicines'] = this.medicines;
    data['pdf'] = this.pdf;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['pdfPath'] = this.pdfPath;
    if (this.items != null) {
      data['items'] = this.items!.map((e) => e.toJson()).toList();
    }
    data['treatment_recommendation'] = this.treatmentRecommendation;
    return data;
  }
}
