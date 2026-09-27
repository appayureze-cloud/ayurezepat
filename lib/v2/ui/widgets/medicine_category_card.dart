import 'package:cached_network_image/cached_network_image.dart';
import 'package:doctro_patient/model/v2/medicine/medicine_home_response.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:sizer/sizer.dart';

import '../../../const/Palette.dart';

class MedicineCategoryCard extends HookWidget {
  final PopularCategories category;

  const MedicineCategoryCard(
      {required this.category,
      super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushReplacementNamed(context, 'MedicineHome',
            arguments: [2, category.id]);
      },
      child: SizedBox(
        // height: 15.h,
        width: 30.w,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4.w),
          ),
          elevation: 2,
          margin: EdgeInsets.symmetric(vertical: 0.5.h),
          child: Padding(
            padding: EdgeInsets.all(2.w),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(4.w),
                  child: CachedNetworkImage(
                    height: 20.w,
                    width: 20.w,
                    alignment: Alignment.center,
                    imageUrl: category.image ?? '',
                    fit: BoxFit.cover,
                    placeholder: (context, url) => SpinKitFadingCircle(
                      color: Palette.primary,
                    ),
                    errorWidget: (context, url, error) => Image.asset(
                      "assets/images/NoImage.png",
                      fit: BoxFit.fitHeight,
                    ),
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  '${category.name}' * 2,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                    overflow: TextOverflow.ellipsis,
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
