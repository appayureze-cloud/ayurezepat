import 'package:cached_network_image/cached_network_image.dart';
import 'package:doctro_patient/model/v2/appointment_list_response.dart';
import 'package:doctro_patient/v2/utils/helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

import '../../../const/Palette.dart';
import '../appointment/appointment_details.dart';

class AppointmentCard_v2 extends HookWidget {
  final AppointmentListItemModal appointment;

  const AppointmentCard_v2({required this.appointment});

  String get _dateTime {
    final DateTime startTime = DateFormat("yyyy-MM-dd hh:mm a")
        .parse('${appointment.date} ${appointment.time}');
    final DateTime endTime =
        startTime.add(Duration(minutes: appointment.duration ?? 0));
    return '${DateFormat("EEE, MMM dd . hh:mm a").format(startTime)} to ${DateFormat("hh:mm a").format(endTime)}';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => AppointmentDetails(details: appointment)));
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 4.w,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 1.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$_dateTime',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 3.w),
                Text(
                  '${appointment.appointmentStatus == 'approve' ? 'Active' : appointment.appointmentStatus == 'cancel' ? 'Cancelled' : appointment.appointmentStatus!.toSentenceCase()}',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: appointment.appointmentStatus == 'approve'
                        ? Palette.primary
                        : appointment.appointmentStatus == 'cancel'
                            ? Palette.red
                            : Palette.rating,
                  ),
                ),
              ],
            ),
            SizedBox(height: 1.h),
            Row(
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15.w),
                      child: CachedNetworkImage(
                        imageUrl: appointment.doctor?.fullImage ?? '',
                        fit: BoxFit.cover,
                        height: 15.w,
                        width: 15.w,
                        placeholder: (context, url) => Center(
                          child: CircularProgressIndicator(),
                        ),
                        errorWidget: (context, url, error) => Center(
                          child: Image.asset(
                            "assets/images/NoImage.png",
                            fit: BoxFit.fitHeight,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 1.w,
                      bottom: 1.w,
                      child: Icon(
                        Icons.circle,
                        size: 3.w,
                        color: Palette.green,
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 4.w),
                SizedBox(
                  width: 55.w,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${appointment.appointmentType!.toSentenceCase()} visit with',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: Palette.green,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        'Dr. ${appointment.doctor!.name}',
                        style: TextStyle(
                          fontSize: 17.sp,
                          fontWeight: FontWeight.w600,
                          color: Palette.black,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        '${appointment.doctor!.category!.name}',
                        style: TextStyle(
                          fontSize: 15.sp,
                          color: Palette.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 4.w),
                Spacer(),
                Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.h),
                    color: Palette.primary.withValues(alpha: 0.15),
                  ),
                  child: Icon(
                    appointment.appointmentType == 'video'
                        ? Icons.video_camera_back
                        : Icons.phone,
                    color: Palette.primary,
                    size: 18.sp,
                  ),
                ),
              ],
            ),
            SizedBox(height: 1.h),
            Divider(),
            SizedBox(height: 1.h),
          ],
        ),
      ),
    );
  }
}
