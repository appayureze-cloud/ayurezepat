import 'package:cached_network_image/cached_network_image.dart';
import 'package:doctro_patient/const/prefConstatnt.dart';
import 'package:doctro_patient/const/preference.dart';
import 'package:doctro_patient/model/v2/home_response.dart';
import 'package:doctro_patient/v2/ui/appointment/make_appointment.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:sizer/sizer.dart';

import '../../../const/Palette.dart';
import 'button_v2.dart';

class DoctorInfoCard_v2 extends HookWidget {
  final Doctor doctor;

  const DoctorInfoCard_v2({required this.doctor, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
      decoration: BoxDecoration(
        border: Border.all(
          color: Palette.grey.withValues(alpha: .5),
        ),
        borderRadius: BorderRadius.circular(2.w),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 2.w, top: 1.5.h, right: 2.w),
                child: Badge(
                  backgroundColor: Palette.rating,
                  smallSize: 1.h,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(2.w),
                    child: CachedNetworkImage(
                      height: 15.w,
                      width: 15.w,
                      alignment: Alignment.center,
                      imageUrl: doctor.fullImage ?? '',
                      fit: BoxFit.cover,
                      placeholder: (context, url) => SpinKitFadingCircle(
                        color: Palette.primary,
                      ),
                      errorWidget: (context, url, error) => Image.asset(
                        "assets/images/no_image.jpg",
                        fit: BoxFit.fitHeight,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: 2.w, top: 1.5.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dr. ${doctor.name}',
                        style: TextStyle(
                          color: Palette.black,
                          fontSize: 16.sp,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        '${doctor.category?.name}',
                        style: TextStyle(
                          color: Palette.grey,
                          fontSize: 14.5.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.work,
                            color: Palette.primary,
                            size: 4.w,
                          ),
                          SizedBox(width: 1.w),
                          Text(
                            '${doctor.experience} years',
                            style: TextStyle(
                              color: Palette.grey,
                              fontSize: 14.sp,
                            ),
                          ),
                          SizedBox(width: 3.w),
                          Icon(
                            Icons.star,
                            color: Palette.rating,
                            size: 5.w,
                          ),
                          SizedBox(width: 0.5.w),
                          Text(
                            '${doctor.rate}',
                            style: TextStyle(
                              color: Palette.grey,
                              fontSize: 14.sp,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 0.5.h),
          Divider(),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 3.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Starting from',
                      style: TextStyle(
                        color: Palette.grey,
                        fontSize: 14.sp,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      '${SharedPreferenceHelper.getString(Preferences.currency_symbol)} ${doctor.appointmentFees} / ${doctor.timeslot == 'other' ? doctor.customTimeslot : doctor.timeslot} mins',
                      style: TextStyle(
                        color: Palette.black,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                ButtonV2(
                  width: 25.w,
                  label: 'Book',
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => MakeAppointment(doctor: doctor)));
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: 0.5.h),
        ],
      ),
    );
  }
}
