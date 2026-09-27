import 'package:doctro_patient/model/v2/therapy_home_response.dart';

import '../v2/show_address_model.dart';

class MakeTherapyBookingModal {
  final String bookingFor;
  final String name;
  final String age;
  final Address address;
  final String phoneCode;
  final String phone;
  final DateTime date;
  final Centers center;
  final Packages? package;
  final Services? service;
  final int duration;

  MakeTherapyBookingModal({
    required this.bookingFor,
    required this.name,
    required this.age,
    required this.address,
    required this.phoneCode,
    required this.phone,
    required this.date,
    required this.center,
    required this.duration,
    this.package,
    this.service,
  }) : assert(
          ((service != null || package != null) ||
              (service != null) ^ (package != null)),
          'Either service or package must be provided, but not both.',
        );

  factory MakeTherapyBookingModal.fromJson(Map<String, dynamic> json) {
    return MakeTherapyBookingModal(
      bookingFor: json['bookingFor'],
      name: json['name'],
      age: json['age'],
      duration: json['duration'],
      address: Address.fromJson(json['address']),
      phoneCode: json['phoneCode'],
      phone: json['phone'],
      date: DateTime.parse(json['date']),
      center: Centers.fromJson(json['center']),
      package:
          json['package'] != null ? Packages.fromJson(json['package']) : null,
      service:
          json['service'] != null ? Services.fromJson(json['service']) : null,
    );
  }
}
