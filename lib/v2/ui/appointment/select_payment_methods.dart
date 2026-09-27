import 'package:doctro_patient/const/prefConstatnt.dart';
import 'package:doctro_patient/const/preference.dart';
import 'package:doctro_patient/features/case/presentation/case_service.dart';
import 'package:doctro_patient/features/payments/domain/payment_repository.dart';
import 'package:doctro_patient/features/payments/presentation/payment_service.dart';
import 'package:doctro_patient/model/v2/display_offer_model.dart';
import 'package:doctro_patient/v2/ui/appointment/payment_result.dart';
import 'package:doctro_patient/v2/ui/widgets/button_v2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:sizer/sizer.dart';

import '../../../api/network_api.dart';
import '../../../api/retrofit_Api.dart';
import '../../../const/Palette.dart';
import '../../../model/v2/book_appointments_model.dart';
import '../../../model/v2/make_appointment.dart';
import '../../utils/logger.dart';
import '../widgets/header.dart';
import '../widgets/payment_card.dart';

class SelectAppointmentPaymentMethods extends HookWidget {
  final MakeAppointmentModal details;
  final double fees;
  final Coupon? coupon;
  final double discount;

  SelectAppointmentPaymentMethods(
      {required this.details,
      required this.fees,
      required this.discount,
      super.key,
      required this.coupon});

  final int? isRazorEnabled = SharedPreferenceHelper.getInt(Preferences.razor);
  final int? isCodEnabled = SharedPreferenceHelper.getInt(Preferences.cod);

  @override
  Widget build(BuildContext context) {
    ValueNotifier<String?> selectedPaymentType =
        useState(isRazorEnabled == 1 ? 'razorpay' : null);
    ValueNotifier<bool> loading = useState(false);

    Future<void> bookAppointment(
        {String? paymentReference, String? caseId}) async {
      try {
        final dio = await RetroApi().dioData(context);
        final resolvedCaseId =
            caseId ?? (await CaseService.withDio(dio).ensureActiveCase()).id;

        Map<String, dynamic> body = {
          "case_id": resolvedCaseId,
          "appointment_for": details.bookingFor,
          "hospital_id": details.hospital.id,
          "patient_name": details.name,
          "illness_information": details.illness,
          "age": details.age,
          "patient_address": details.address.id,
          "phone_no": details.phone,
          "phone_code": details.phoneCode,
          "drug_effect": details.sideEffects,
          "appointment_type": details.type,
          "note": details.note.isNotEmpty ? details.note : "No note",
          "date": DateFormat("yyyy-MM-dd").format(details.date),
          "time": DateFormat("hh:mm a").format(details.date),
          "duration": int.tryParse('${details.doctor.timeslot}') ?? 30,
          "payment_type": selectedPaymentType.value,
          "payment_reference": paymentReference,
          "doctor_id": details.doctor.id,
          "report_image": "",
          "discount_id": coupon?.id,
        };
        logger.i(body);

        loading.value = true;
        BookingResponse response = await RestClient(dio).bookAppointment(body);

        Fluttertoast.showToast(
          msg: '${response.msg}',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
        );

        Preferences.hideDialog(context);
        if (response.success == true)
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => PaymentResult(
                  adetails: details,
                  tdetails: null,
                  from: 'appointment',
                  bookingId: response.success == true ? response.data : null),
            ),
          );
      } catch (error, stacktrace) {
        Preferences.hideDialog(context);
        logger.e("Exception occur: $error stackTrace: $stacktrace");
        Fluttertoast.showToast(
            msg: "Booking failed", toastLength: Toast.LENGTH_SHORT);
      } finally {
        loading.value = false;
      }
    }

    Future<void> payWithRazorpay() async {
      loading.value = true;
      try {
        final dio = await RetroApi().dioData(context);
        final caseModel = await CaseService.withDio(dio).ensureActiveCase();
        final paymentReference = await PaymentService.withDio(dio).charge(
          purpose: PaymentRepository.purposeAppointment,
          caseId: caseModel.id,
          reference: {
            'doctor_id': details.doctor.id,
            'hospital_id': details.hospital.id,
            'discount_id': coupon?.id,
          },
          contactPhone: details.phone,
          contactEmail:
              SharedPreferenceHelper.getString(FirestoreConstants.email),
        );
        await bookAppointment(
            paymentReference: paymentReference, caseId: caseModel.id);
      } on PaymentCancelledException {
        loading.value = false;
      } catch (e) {
        loading.value = false;
        logger.e('Payment failed: $e');
        Fluttertoast.showToast(
            msg: "Payment Failed", toastLength: Toast.LENGTH_SHORT);
      }
    }

    return SafeArea(
      child: ModalProgressHUD(
        inAsyncCall: loading.value,
        opacity: 0.5,
        progressIndicator: SpinKitFadingCircle(
          color: Palette.primary,
          size: 3.h,
        ),
        child: Scaffold(
          body: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Header_v2(
                title: 'Payment Method',
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 2.w,
                  vertical: 1.h,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 1.h),
                    Text(
                      'Select a Payment Method you want to use',
                      style: TextStyle(
                        color: Palette.black,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    if (isRazorEnabled == 1)
                      PaymentCard(
                        selectedPaymentType: selectedPaymentType,
                        title: 'Razorpay',
                        value: 'razorpay',
                      ),
                    if (isCodEnabled == 1)
                      PaymentCard(
                        selectedPaymentType: selectedPaymentType,
                        title: 'COD',
                        value: 'cod',
                      ),
                    SizedBox(height: 2.h),
                    ButtonV2(
                      label:
                          'Pay ${SharedPreferenceHelper.getString(Preferences.currency_symbol)} ${fees}',
                      onPressed: () {
                        if (selectedPaymentType.value != null) {
                          switch (selectedPaymentType.value) {
                            case 'razorpay':
                              {
                                payWithRazorpay();
                                break;
                              }
                            case 'cod':
                              {
                                loading.value = true;
                                bookAppointment();
                                break;
                              }
                          }
                        } else {
                          Fluttertoast.showToast(
                              msg: "Please select payment method",
                              toastLength: Toast.LENGTH_SHORT);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
