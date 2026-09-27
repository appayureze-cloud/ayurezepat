import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

import '../../../const/Palette.dart';
import '../../../model/v2/make_appointment.dart';
import '../../../model/v2/make_therapy_booking_modal.dart';

class PaymentResult extends HookWidget {
  final String from;
  final String? bookingId;
  final MakeTherapyBookingModal? tdetails;
  final MakeAppointmentModal? adetails;

  const PaymentResult(
      {required this.from,
      required this.bookingId,
      required this.adetails,
      required this.tdetails,
      super.key});

  @override
  Widget build(BuildContext context) {
    void redirectToHome() async {
      await Future.delayed(Duration(seconds: 3));
      if (from == 'appointment') {
        Navigator.pushNamedAndRemoveUntil(context, 'Home', (_) => false);
      } else {
        Navigator.pushNamedAndRemoveUntil(context, 'TherapyHome', (_) => false);
      }
    }

    useEffect(() {
      redirectToHome();
    }, []);
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 2.w,
          vertical: 1.h,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 15.h),
            SvgPicture.asset(
              'assets/images/success.svg',
              height: 50.w,
              width: 50.w,
            ),
            SizedBox(height: 5.h),
            Text(
              'Thank You !',
              style: TextStyle(
                color: Palette.black,
                fontSize: 23.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              'Your ${from == 'appointment' ? 'Appointment' : ' Booking'} Successful!',
              style: TextStyle(
                color: Palette.grey,
                fontSize: 18.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(height: 1.5.h),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 15.w,
              ),
              child: Text(
                'You booked ${from == 'appointment' ? 'an appointment' : 'a therapy session'} with ${from == 'appointment' ? "Dr. ${adetails!.doctor.name}" : "${tdetails!.center.name}"} on ${DateFormat("EEEE dd,yyyy @ hh:mm a").format(DateTime.parse('${from == 'appointment' ? adetails!.date : tdetails!.date}'))}',
                style: TextStyle(
                  color: Palette.grey,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 3.h),
          ],
        ),
      ),
    );
  }
}
