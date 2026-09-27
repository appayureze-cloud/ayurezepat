import 'package:doctro_patient/const/prefConstatnt.dart';
import 'package:doctro_patient/const/preference.dart';
import 'package:doctro_patient/model/v2/therapy_home_response.dart';
import 'package:doctro_patient/v2/ui/widgets/therapy_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:sizer/sizer.dart';

import '../../../const/Palette.dart';

class TherapyPackageCard extends HookWidget {
  final bool showOffer;
  final Packages package;

  const TherapyPackageCard(
      {required this.package, this.showOffer = true, super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100.w,
      child: Card(
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 3.w,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 5.h),
                  Text(
                    '${package.packageName}',
                    softWrap: true,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                      color: Palette.primary,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  IntrinsicHeight(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        for (int i = 0; i < package.services!.length; i++) ...[
                          TherapyCard(
                            service: package.services![i],
                            width: 38.w,
                            titleSize: 14.sp,
                            subTitleSize: 12.sp,
                            iconSize: 16.sp,
                            hidePrice: true,
                          ),
                          SizedBox(width: 1.w),
                          if (i < package.services!.length - 1)
                            Center(
                              child: Icon(
                                Icons.add,
                                size: 2.h,
                              ),
                            ),
                          if (i < package.services!.length - 1)
                            SizedBox(width: 1.w),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    '${package.center!.name}',
                    style: TextStyle(
                      color: Palette.black,
                      fontWeight: FontWeight.w600,
                      fontSize: 16.sp,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    '${package.center!.address}',
                    style: TextStyle(
                      color: Palette.black,
                      fontWeight: FontWeight.w500,
                      fontSize: 14.sp,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Row(
                    children: [
                      IgnorePointer(
                        child: RatingBar.builder(
                          initialRating:
                              double.tryParse('${package.center!.rate}') ?? 0,
                          minRating: 1,
                          direction: Axis.horizontal,
                          allowHalfRating: true,
                          itemCount: 5,
                          itemSize: 4.w,
                          itemBuilder: (context, _) => Icon(
                            Icons.star,
                            color: Palette.rating,
                          ),
                          onRatingUpdate: (double value) {},
                        ),
                      ),
                      Text(
                        '(${package.center!.review})',
                        style: TextStyle(
                          color: Palette.grey,
                          fontWeight: FontWeight.w500,
                          fontSize: 2.5.w,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  RichText(
                    text: TextSpan(
                      text:
                          '${SharedPreferenceHelper.getString(Preferences.currency_symbol)} ${package.fees}',
                      style: TextStyle(
                        color: Palette.green,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                      ),
                      children: [
                        TextSpan(
                          text: ' / ${package.duration} mins',
                          style: TextStyle(
                            color: Palette.green,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    'One time payment',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Palette.grey,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: 1.h),
                ],
              ),
            ),
            if (showOffer == true)
              Positioned(
                left: 0,
                top: 0,
                child: Container(
                  padding: EdgeInsets.all(2.w),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Palette.green,
                    borderRadius: BorderRadius.circular(1.w),
                  ),
                  child: Text(
                    '${(((package.services!.fold(
                              0.0,
                              (sum, item) => sum + double.parse(item.fees!),
                            ) - double.parse('${package.fees}')) * 100) / package.services!.fold(
                          0.0,
                          (sum, item) => sum + double.parse(item.fees!),
                        )).abs().toStringAsPrecision(2)}% off',
                    style: TextStyle(
                      color: Palette.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15.sp,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
