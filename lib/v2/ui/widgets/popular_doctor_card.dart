import 'package:cached_network_image/cached_network_image.dart';
import 'package:doctro_patient/model/v2/home_response.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:sizer/sizer.dart';

import '../../../const/Palette.dart';
import '../appointment/make_appointment.dart';

class PopularDoctorCard extends HookWidget {
  final Doctor doctor;

  const PopularDoctorCard({required this.doctor, super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => MakeAppointment(doctor: doctor)));
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
                  imageUrl: doctor.fullImage ?? '',
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
                      '${doctor.name}',
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
                        fontSize: 15.sp,
                      ),
                    ),
                    if ((doctor.education?.length ?? 0) > 0)
                      SizedBox(height: 0.5.h),
                    if ((doctor.education?.length ?? 0) > 0)
                      Text(
                        '${doctor.education?.map((e) => e.degree!.toUpperCase()).join(', ')}',
                        style: TextStyle(
                          color: Palette.grey.withValues(alpha: .8),
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    SizedBox(height: 1.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(width: 1.w),
                        Icon(
                          Icons.work,
                          size: 16.sp,
                          color: Palette.primary,
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          '${doctor.experience} Years',
                          style: TextStyle(
                            color: Palette.grey,
                            fontSize: 13.sp,
                          ),
                        ),
                        SizedBox(width: 2.w),
                        Spacer(),
                        Icon(
                          Icons.star,
                          size: 16.sp,
                          color: Palette.rating,
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          '${doctor.rate} (${doctor.review})',
                          style: TextStyle(
                            color: Palette.grey,
                            fontSize: 13.sp,
                          ),
                        ),
                        SizedBox(width: 1.w),
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
