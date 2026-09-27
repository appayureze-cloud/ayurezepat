import 'package:doctro_patient/const/prefConstatnt.dart';
import 'package:doctro_patient/const/preference.dart';
import 'package:doctro_patient/model/v2/make_appointment.dart';
import 'package:doctro_patient/v2/ui/appointment/select_payment_methods.dart';
import 'package:doctro_patient/v2/ui/others/coupons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

import '../../../const/Palette.dart';
import '../../../model/v2/display_offer_model.dart';
import '../../utils/helper.dart';
import '../widgets/appointment_section_card.dart';
import '../widgets/button_v2.dart';
import '../widgets/header.dart';

class ConfirmAppointmentDetails extends HookWidget {
  final MakeAppointmentModal details;

  const ConfirmAppointmentDetails({
    super.key,
    required this.details,
  });

  @override
  Widget build(BuildContext context) {
    ValueNotifier<Coupon?> coupon = useState(null);
    ValueNotifier<double> total = useState(0);
    ValueNotifier<double> grandTotal = useState(0);
    ValueNotifier<double> discountAmt = useState(0);

    void calculateDiscount() {
      double fees = double.parse(
          '${details.type == 'video' ? details.doctor.videoAppointmentFees : details.doctor.appointmentFees}');

      total.value = fees;

      if (coupon.value == null) {
        grandTotal.value = fees;
        discountAmt.value = 0;
        return;
      }

      var discountType = coupon.value!.discountType!.toUpperCase();
      var flatDiscount = coupon.value!.flatDiscount;
      var isFlat = coupon.value!.isFlat;
      var minDiscount = coupon.value!.minDiscount;
      var discount = coupon.value!.discount;
      double newFees = fees;
      double appliedDiscount = 0;

      bool isCouponValid = false;
      String toastMessage = "";

      if (discountType == "AMOUNT" && isFlat == 1) {
        if (fees > flatDiscount!) {
          appliedDiscount =
              flatDiscount < minDiscount! ? flatDiscount : minDiscount;
          newFees = fees - appliedDiscount;
          isCouponValid = true;
          toastMessage = "Offer applied";
        } else {
          toastMessage = "Amount should be more than " +
              SharedPreferenceHelper.getString(Preferences.currency_symbol)
                  .toString() +
              '$flatDiscount.';
        }
      } else if (discountType == "AMOUNT" && isFlat == 0) {
        if (fees > discount!) {
          appliedDiscount = discount < minDiscount! ? discount : minDiscount;
          newFees = fees - appliedDiscount;
          isCouponValid = true;
          toastMessage = "Offer applied";
        } else {
          toastMessage = "Amount should be more than " +
              SharedPreferenceHelper.getString(Preferences.currency_symbol)
                  .toString() +
              '$discount.';
        }
      } else if (discountType == "PERCENTAGE") {
        var prAmount = (fees * discount!) / 100;
        appliedDiscount = prAmount <= minDiscount! ? prAmount : minDiscount;
        newFees = fees - appliedDiscount;
        isCouponValid = true;
        toastMessage = "Offer applied";
      }

      double maxAllowedDiscount = fees * 0.25;

      if (!isCouponValid || appliedDiscount > maxAllowedDiscount) {
        // Invalid or too much discount
        coupon.value = null;
        grandTotal.value = fees.ceilToDouble();
        discountAmt.value = 0;

        Fluttertoast.showToast(
          msg: appliedDiscount > maxAllowedDiscount
              ? "Coupon not applied. Discount cannot exceed 25% of the fees."
              : toastMessage,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
        );
        return;
      }

      // Valid and within 25%
      grandTotal.value = newFees.ceilToDouble();
      discountAmt.value = appliedDiscount.ceilToDouble();

      Fluttertoast.showToast(
        msg: toastMessage,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
      );
    }

    useEffect(() {
      calculateDiscount();
    }, [coupon.value]);
    useEffect(() {
      calculateDiscount();
    }, []);

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Header_v2(
              title: 'Appointment Details',
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 3.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // DoctorDetailsCard(),
                  SizedBox(height: 3.h),
                  AppointmentSectionCard(
                    icon: Icon(
                      Icons.access_time_rounded,
                      size: 6.w,
                      color: Palette.black,
                    ),
                    title: 'Appointment time',
                    subTitle:
                        DateFormat('EEE, dd MMM hh:mm a').format(details.date),
                    description: timeUntil(details.date),
                  ),
                  SizedBox(height: 1.h),
                  AppointmentSectionCard(
                    icon: SvgPicture.asset(
                      'assets/icons/clinic.svg',
                      height: 6.w,
                      width: 6.w,
                    ),
                    title: 'Clinic Details',
                    subTitle:
                        '${details.hospital.hospitalName}\n${details.hospital.address}',
                  ),
                  SizedBox(height: 1.h),
                  AppointmentSectionCard(
                    icon: Icon(
                      Icons.person_outline_sharp,
                      size: 6.w,
                      color: Palette.black,
                    ),
                    title: '${details.type.toSentenceCase()} Appointment for',
                    subTitle:
                        '${details.name} (${details.bookingFor.toSentenceCase()})',
                  ),
                  SizedBox(height: 1.h),
                  AppointmentSectionCard(
                    icon: Icon(
                      Icons.local_hospital_outlined,
                      size: 6.w,
                    ),
                    title: 'Other Details',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Divider(),
                        paymentSection(
                            title: 'Patient Age',
                            value: details.age.toSentenceCase()),
                        paymentSection(
                            title: 'Phone',
                            value: details.phoneCode + ' ' + details.phone),
                        paymentSection(
                            title: 'Illness',
                            value: details.illness.toSentenceCase()),
                        paymentSection(
                            title: 'Side Effects',
                            value: details.sideEffects.toSentenceCase()),
                        paymentSection(
                            title: 'Note',
                            value: details.note.toSentenceCase()),
                        paymentSection(
                            title: 'Address',
                            value: details.address.address!.toSentenceCase()),
                      ],
                    ),
                  ),
                  SizedBox(height: 1.h),
                  GestureDetector(
                    onTap: () {
                      if (coupon.value == null) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => CouponsScreen(
                                      from: 'appointment',
                                      date: details.date,
                                      doctorId: details.doctor.id!,
                                    ))).then((val) {
                          if (val is Coupon) coupon.value = val;
                        });
                      } else {
                        coupon.value = null;
                      }
                    },
                    child: AppointmentSectionCard(
                      icon: SvgPicture.asset(
                        'assets/icons/coupon.svg',
                        height: 6.w,
                        width: 6.w,
                      ),
                      title: coupon.value == null
                          ? 'Apply Coupon'
                          : 'Coupon Applied',
                      subTitle: coupon.value == null
                          ? 'Unlock Offers with coupon code'
                          : coupon.value!.offerCode!.toUpperCase() +
                              ' (${SharedPreferenceHelper.getString(Preferences.currency_symbol)} ${discountAmt.value})',
                      description: coupon.value == null ? 'Select' : 'Remove',
                      descriptionColor:
                          coupon.value == null ? Palette.primary : Palette.red,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    'Bill Details',
                    style: TextStyle(
                      color: Palette.black,
                      fontSize: 18.sp,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  paymentSection(
                    title: 'Consultation Fee',
                    value:
                        '${SharedPreferenceHelper.getString(Preferences.currency_symbol)} ${double.parse((details.type == 'video' ? details.doctor.videoAppointmentFees : details.doctor.appointmentFees)!)}',
                  ),
                  if (coupon.value != null)
                    paymentSection(
                      title: 'Selected Coupon',
                      value: '${coupon.value!.offerCode}',
                      valueColor: Palette.primary,
                    ),
                  if (coupon.value != null)
                    paymentSection(
                        title: 'Discount',
                        value:
                            '${SharedPreferenceHelper.getString(Preferences.currency_symbol)} ${discountAmt.value}'),

                  // SizedBox(height: 1.5.h),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.end,
                  //   children: [
                  //     Text(
                  //       'Service fee & Tax',
                  //       style: TextStyle(
                  //         color: Palette.black,
                  //         fontSize: 15.sp,
                  //         fontWeight: FontWeight.w400,
                  //       ),
                  //     ),
                  //     SizedBox(width: 2.w),
                  //     Text(
                  //       'Free',
                  //       style: TextStyle(
                  //         color: Palette.primary,
                  //         fontSize: 14.sp,
                  //         fontWeight: FontWeight.w400,
                  //       ),
                  //     ),
                  //     Spacer(),
                  //     Text(
                  //       '${SharedPreferenceHelper.getString(Preferences.currency_symbol)} 49',
                  //       style: TextStyle(
                  //         color: Palette.black,
                  //         fontSize: 15.sp,
                  //         fontWeight: FontWeight.w400,
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  // SizedBox(height: 1.h),
                  // Text(
                  //   'We care for you & provide free appointment',
                  //   style: TextStyle(
                  //     color: Palette.primary,
                  //     fontSize: 14.sp,
                  //     fontWeight: FontWeight.w400,
                  //   ),
                  // ),
                  // SizedBox(height: 3.h),
                  Divider(),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 2.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${SharedPreferenceHelper.getString(Preferences.currency_symbol)} ${grandTotal.value}',
                              style: TextStyle(
                                color: Palette.black,
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            SizedBox(height: 1.h),
                            Text(
                              'View Cancellation Policy',
                              style: TextStyle(
                                color: Palette.primary,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(width: 2.w),
                        SizedBox(
                          width: 50.w,
                          child: ButtonV2(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          SelectAppointmentPaymentMethods(
                                            details: details,
                                            coupon: coupon.value,
                                            fees: grandTotal.value,
                                            discount: discountAmt.value,
                                          )));
                            },
                            label: 'Pay & Book',
                            buttonColor: Palette.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 2.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
