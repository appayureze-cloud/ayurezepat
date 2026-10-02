import 'package:cached_network_image/cached_network_image.dart';
import 'package:doctro_patient/const/Palette.dart';
import 'package:doctro_patient/model/v2/therapy_booking_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

import '../therapy/therapy_booking_details.dart';
import 'button_v2.dart';

class TherapyBookingCard extends HookWidget {
  final bool showBookAgain;
  final TherapyBooking booking;
  final Color? bgColor;

  const TherapyBookingCard(
      {required this.booking,
      this.showBookAgain = false,
      this.bgColor,
      super.key});

  String get _dateTime {
    final DateTime startTime = DateFormat("yyyy-MM-dd hh:mm a")
        .parse('${booking.date} ${booking.time}');
    final DateTime endTime =
        startTime.add(Duration(minutes: booking.duration ?? 0));
    return '${DateFormat("EEE, MMM dd . hh:mm a").format(startTime)} to ${DateFormat("hh:mm a").format(endTime)}';
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100.w,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => TherapyBookingDetailsScreen(
                        details: booking,
                      )));
        },
        child: Card(
          // color: bgColor ?? Palette.lightGrey2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(2.w),
          ),
          elevation: 2,
          margin: EdgeInsets.symmetric(
            horizontal: 2.w,
            vertical: 0.5.h,
          ),
          child: Padding(
            padding: EdgeInsets.all(2.w),
            child: Column(
              children: [
                Row(
                  children: [
                    booking.package != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(2.w),
                            child: CachedNetworkImage(
                              imageUrl:
                                  '${booking.center!.gallery!.isNotEmpty ? booking.center!.gallery!.first : ''}',
                              fit: BoxFit.cover,
                              height: 7.h,
                              width: 7.h,
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
                          )
                        : Text(
                            '${booking.service!.icon}',
                            style: TextStyle(
                              fontSize: 25.sp,
                            ),
                          ),
                    SizedBox(width: 5.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${booking.center!.name}',
                          style: TextStyle(
                            color: Palette.black,
                            fontWeight: FontWeight.w600,
                            fontSize: 16.sp,
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          '${booking.center!.address}',
                          style: TextStyle(
                            color: Palette.grey,
                            fontWeight: FontWeight.w500,
                            fontSize: 14.sp,
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          '${booking.service?.name ?? booking.package!.packageName}',
                          style: TextStyle(
                            color: Palette.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 14.sp,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Divider(color: Palette.grey),
                        SizedBox(height: 0.5.h),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 16.sp,
                            ),
                            SizedBox(width: 2.w),
                            Text(
                              '$_dateTime',
                              style: TextStyle(
                                color: Palette.black,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                if (showBookAgain) Divider(),
                if (showBookAgain)
                  SizedBox(
                    width: 100.w,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: SmallButton(
                        label: 'Book again',
                        buttonColor: Palette.primary,
                        fontSize: 15.sp,
                        width: 35.w,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
