import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:sizer/sizer.dart';

import '../../../const/Palette.dart';
import '../../../features/appointments/domain/entities/doctor_summary.dart';
import '../../../features/appointments/presentation/doctor_booking_screen.dart';

class PopularDoctorCard extends HookWidget {
  final DoctorSummary doctor;

  const PopularDoctorCard({required this.doctor, super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => DoctorBookingScreen(doctor: doctor)));
      },
      child: Card(
        margin: EdgeInsets.symmetric(
          vertical: 0.5.h,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4.w),
        ),
        child: SizedBox(
          width: 45.w,
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4.w),
                child: CachedNetworkImage(
                  imageUrl: doctor.photoUrl ?? '',
                  fit: BoxFit.fitWidth,
                  height: 12.h,
                  width: 45.w,
                  placeholder: (context, url) => Center(
                    child: CircularProgressIndicator(),
                  ),
                  errorWidget: (context, url, error) => Center(
                    child: Image.asset(
                      "assets/images/no_image.jpg",
                      fit: BoxFit.fitHeight,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 2.5.w,
                  vertical: 1.h,
                ),
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
                    if ((doctor.specialization ?? '').isNotEmpty)
                      Text(
                        doctor.specialization!,
                        style: TextStyle(
                          color: Palette.grey,
                          fontSize: 15.sp,
                        ),
                      ),
                    if (doctor.isVerified) SizedBox(height: 0.5.h),
                    if (doctor.isVerified)
                      Row(
                        children: [
                          Icon(
                            Icons.verified,
                            size: 14.sp,
                            color: Palette.primary,
                          ),
                          SizedBox(width: 1.w),
                          Text(
                            'Verified',
                            style: TextStyle(
                              color: Palette.grey,
                              fontSize: 12.sp,
                            ),
                          ),
                        ],
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
