import 'package:cached_network_image/cached_network_image.dart';
import 'package:doctro_patient/model/v2/home_response.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:sizer/sizer.dart';

import '../../../const/Palette.dart';

class DoctorDetailsCard extends HookWidget {
  final Doctor doctor;

  const DoctorDetailsCard({required this.doctor});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          margin: EdgeInsets.symmetric(
            vertical: 0.5.h,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(2.w),
          ),
          child: Padding(
            padding: EdgeInsets.all(3.w),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(5.h),
                  child: CachedNetworkImage(
                    imageUrl: doctor.fullImage ?? '',
                    fit: BoxFit.cover,
                    height: 10.h,
                    width: 10.h,
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
                SizedBox(width: 2.w),
                Column(
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
                        fontSize: 15.sp,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      '${doctor.education?.map((e) => e.degree).join()}',
                      style: TextStyle(
                        color: Palette.grey,
                        fontSize: 14.sp,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                  ],
                ),
              ],
            ),
          ),
        ),
        Card(
          margin: EdgeInsets.symmetric(
            vertical: 0.5.h,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(2.w),
          ),
          child: Padding(
            padding: EdgeInsets.all(3.w),
            child: IntrinsicHeight(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(width: 1.w),
                  Icon(
                    Icons.work,
                    size: 18.sp,
                    color: Palette.primary,
                  ),
                  SizedBox(width: 1.w),
                  Text(
                    '${doctor.experience} Year(s)',
                    style: TextStyle(
                      color: Palette.grey,
                      fontSize: 15.sp,
                    ),
                  ),
                  SizedBox(width: 1.w),
                  VerticalDivider(),
                  SizedBox(width: 1.w),
                  Icon(
                    Icons.people,
                    size: 18.sp,
                    color: Palette.purple,
                  ),
                  SizedBox(width: 1.5.w),
                  Text(
                    '${doctor.review} Patient(s)',
                    style: TextStyle(
                      color: Palette.grey,
                      fontSize: 15.sp,
                    ),
                  ),
                  SizedBox(width: 1.w),
                  VerticalDivider(),
                  SizedBox(width: 1.w),
                  Icon(
                    Icons.star,
                    size: 18.sp,
                    color: Palette.rating,
                  ),
                  SizedBox(width: 1.w),
                  Text(
                    '${doctor.rate} (${doctor.review})',
                    style: TextStyle(
                      color: Palette.grey,
                      fontSize: 15.sp,
                    ),
                  ),
                  SizedBox(width: 1.w),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
