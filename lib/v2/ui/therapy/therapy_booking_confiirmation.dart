import 'package:doctro_patient/const/prefConstatnt.dart';
import 'package:doctro_patient/const/preference.dart';
import 'package:doctro_patient/model/v2/make_therapy_booking_modal.dart';
import 'package:doctro_patient/v2/ui/therapy/select_payment_methods.dart';
import 'package:doctro_patient/v2/utils/helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

import '../../../const/Palette.dart';
import '../../../model/v2/display_offer_model.dart';
import '../../utils/logger.dart';
import '../others/coupons.dart';
import '../widgets/appointment_section_card.dart';
import '../widgets/button_v2.dart';
import '../widgets/header.dart';
import '../widgets/therapy_center_card.dart';

class TherapyBookingConfirmation extends HookWidget {
  final MakeTherapyBookingModal booking;

  const TherapyBookingConfirmation({
    required this.booking,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    ValueNotifier<Coupon?> coupon = useState(null);
    ValueNotifier<double> total = useState(0);
    ValueNotifier<double> grandTotal = useState(0);
    ValueNotifier<double> discountAmt = useState(0);

    void calculateDiscount() {
      double fees = double.parse(
          '${booking.service != null ? booking.service!.fees : booking.package!.fees}');

      double actualFees = ((fees /
                  double.parse(
                      '${booking.service != null ? booking.service!.duration : booking.package!.duration}')) *
              booking.duration)
          .ceilToDouble();

      total.value = actualFees;

      if (coupon.value == null) {
        grandTotal.value = actualFees;
        discountAmt.value = 0;
        return;
      }

      var discountType = coupon.value!.discountType!.toUpperCase();
      var flatDiscount = coupon.value!.flatDiscount ?? 0;
      var isFlat = coupon.value!.isFlat ?? 0;
      var minDiscount = coupon.value!.minDiscount ?? 0;
      var discount = coupon.value!.discount ?? 0;

      double newFees = actualFees;
      double appliedDiscount = 0;
      bool isCouponValid = false;
      String toastMessage = "";

      if (discountType == "AMOUNT" && isFlat == 1) {
        if (actualFees > flatDiscount) {
          appliedDiscount =
              flatDiscount < minDiscount ? flatDiscount : minDiscount;
          newFees = actualFees - appliedDiscount;
          isCouponValid = true;
          toastMessage = "Offer applied";
        } else {
          toastMessage = "Amount should be more than " +
              SharedPreferenceHelper.getString(Preferences.currency_symbol)
                  .toString() +
              '$flatDiscount.';
        }
      } else if (discountType == "AMOUNT" && isFlat == 0) {
        if (actualFees > discount) {
          appliedDiscount = discount < minDiscount ? discount : minDiscount;
          newFees = actualFees - appliedDiscount;
          isCouponValid = true;
          toastMessage = "Offer applied";
        } else {
          toastMessage = "Amount should be more than " +
              SharedPreferenceHelper.getString(Preferences.currency_symbol)
                  .toString() +
              '$discount.';
        }
      } else if (discountType == "PERCENTAGE") {
        double prAmount = (actualFees * discount) / 100;
        appliedDiscount = prAmount <= minDiscount ? prAmount : minDiscount;
        newFees = actualFees - appliedDiscount;
        isCouponValid = true;
        toastMessage = "Offer applied";
      }

      double maxAllowedDiscount = actualFees * 0.25;

      if (!isCouponValid || appliedDiscount > maxAllowedDiscount) {
        // Invalidate coupon and reset
        coupon.value = null;
        grandTotal.value = actualFees;
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

      // Valid discount
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
              title: 'Confirm Booking Details',
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 3.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TherapyCenterCard(center: booking.center),
                  SizedBox(height: 3.h),
                  AppointmentSectionCard(
                    icon: Icon(
                      Icons.spa_outlined,
                      size: 6.w,
                      color: Palette.black,
                    ),
                    title:
                        'Selected ${(booking.service != null ? 'therapy' : 'package').toSentenceCase()}',
                    subTitle:
                        '${booking.service != null ? booking.service!.name : booking.package!.packageName}',
                    description:
                        '${SharedPreferenceHelper.getString(Preferences.currency_symbol)}'
                        ' ${booking.service != null ? booking.service!.fees : booking.package!.fees} / ${booking.service != null ? booking.service!.duration : booking.package!.duration} mins',
                  ),
                  SizedBox(height: 1.h),
                  AppointmentSectionCard(
                    icon: Icon(
                      Icons.access_time_rounded,
                      size: 6.w,
                      color: Palette.black,
                    ),
                    title: 'Booking time',
                    subTitle:
                        '${DateFormat('EEE, dd MMM hh:mm a').format(booking.date)}',
                    description: timeUntil(booking.date),
                  ),
                  SizedBox(height: 1.h),
                  AppointmentSectionCard(
                    icon: Icon(
                      Icons.person_outline_sharp,
                      size: 6.w,
                      color: Palette.black,
                    ),
                    title: 'Booking for',
                    subTitle:
                        '${booking.name} (${booking.bookingFor.toSentenceCase()})',
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
                            title: 'Age', value: booking.age.toSentenceCase()),
                        paymentSection(
                            title: 'Phone',
                            value: booking.phoneCode + ' ' + booking.phone),
                        paymentSection(
                            title: 'Address',
                            value: booking.address.address!.toSentenceCase()),
                      ],
                    ),
                  ),
                  SizedBox(height: 1.h),
                  GestureDetector(
                    onTap: () {
                      if (coupon.value == null) {
                        logger.i(booking.center.id!);
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => CouponsScreen(
                                      from: 'therapy',
                                      date: booking.date,
                                      therapyCenterId: booking.center.id!,
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
                              ' (${SharedPreferenceHelper.getString(Preferences.currency_symbol)} '
                                  '${discountAmt.value})',
                      description: coupon.value == null ? 'Select' : 'Remove',
                      descriptionColor:
                          coupon.value == null ? Palette.primary : Palette.red,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Divider(),
                  SizedBox(height: 1.h),
                  Text(
                    'Payment Details',
                    style: TextStyle(
                      color: Palette.black,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(
                        width: 70.w,
                        child: Text(
                          'Booking Fee',
                          style: TextStyle(
                            color: Palette.black,
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      Spacer(),
                      Text(
                        '${SharedPreferenceHelper.getString(Preferences.currency_symbol)} ${total.value}',
                        style: TextStyle(
                          color: Palette.black,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 1.5.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Discount',
                        style: TextStyle(
                          color: Palette.black,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Spacer(),
                      Text(
                        '${SharedPreferenceHelper.getString(Preferences.currency_symbol)} ${discountAmt.value}',
                        style: TextStyle(
                          color: Palette.black,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
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
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
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
                                          SelectTherapyPaymentMethods(
                                            details: booking,
                                            coupon: coupon.value,
                                            fees: grandTotal.value,
                                            discount: coupon.value != null
                                                ? discountAmt.value
                                                : 0,
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
