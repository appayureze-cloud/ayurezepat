import 'package:doctro_patient/model/v2/home_response.dart';

import '../v2/show_address_model.dart';

class MakeAppointmentModal {
  final String bookingFor;
  final String name;
  final String age;
  final String sideEffects;
  final Address address;
  final String phoneCode;
  final String phone;
  final String illness;
  final String note;
  final String type;
  final DateTime date;
  final Hospital hospital; // Typo in your code: should be 'hospital'
  final Doctor doctor; // Assuming Doctor is already a defined class

  MakeAppointmentModal({
    required this.bookingFor,
    required this.name,
    required this.age,
    required this.sideEffects,
    required this.address,
    required this.phoneCode,
    required this.phone,
    required this.illness,
    required this.note,
    required this.type,
    required this.date,
    required this.hospital,
    required this.doctor,
  });

  factory MakeAppointmentModal.fromJson(Map<String, dynamic> json) {
    return MakeAppointmentModal(
      bookingFor: json['bookingFor'],
      name: json['name'],
      age: json['age'],
      sideEffects: json['sideEffects'],
      address: Address.fromJson(json['address']),
      phoneCode: json['phoneCode'],
      phone: json['phone'],
      illness: json['illness'],
      note: json['note'],
      type: json['type'],
      date: DateTime.parse(json['date']),
      hospital: Hospital.fromJson(json['hospital']),
      doctor: Doctor.fromJson(json['doctor']),
    );
  }
}
