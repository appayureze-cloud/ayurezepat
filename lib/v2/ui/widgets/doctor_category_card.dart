import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../const/Palette.dart';
import '../../../model/v2/home_response.dart';

class DoctorCategoryCard extends StatelessWidget {
  final DoctorCategory catagory;

  const DoctorCategoryCard({required this.catagory, super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushReplacementNamed(context, 'Home',
            arguments: [1, catagory.id]);
      },
      child: Container(
        width: 24.w,
        padding: EdgeInsets.symmetric(
          horizontal: 2.w,
          vertical: 1.h,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: Palette.lightGrey, width: 0.6),
          borderRadius: BorderRadius.circular(2.w),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(7.w),
              child: CachedNetworkImage(
                  height: 14.w,
                  width: 14.w,
                  imageUrl: catagory.fullImage ?? ''),
            ),
            SizedBox(height: 1.h),
            Text(
              '${catagory.name}',
              style: TextStyle(
                color: Palette.black,
                fontSize: 14.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
