import 'package:doctro_patient/model/v2/therapy_home_response.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../const/Palette.dart';
import '../../../const/prefConstatnt.dart';
import '../../../const/preference.dart';

class TherapyCard extends StatelessWidget {
  final Services service;
  final double? width;
  final double? titleSize;
  final double? subTitleSize;
  final double? iconSize;
  final bool hidePrice;

  const TherapyCard(
      {required this.service,
      this.width,
      this.titleSize,
      this.subTitleSize,
      this.iconSize,
      this.hidePrice = false,
      super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? 100.w,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4.w),
        ),
        elevation: 2,
        margin: EdgeInsets.symmetric(vertical: 0.5.h),
        child: Padding(
          padding: EdgeInsets.all(3.w),
          child: Row(
            children: [
              Text(
                '${service.icon}',
                style: TextStyle(
                  fontSize: iconSize ?? 25.sp,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${service.name}',
                      softWrap: true,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: titleSize ?? 16.sp,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      '${service.description}',
                      style: TextStyle(
                        color: Palette.grey,
                        fontSize: subTitleSize ?? 14.sp,
                      ),
                    ),
                    if (!hidePrice) SizedBox(height: 0.5.h),
                    if (!hidePrice)
                      RichText(
                        text: TextSpan(
                          text:
                              '${SharedPreferenceHelper.getString(Preferences.currency_symbol)} ${service.fees}',
                          style: TextStyle(
                            color: Palette.green,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                          ),
                          children: [
                            TextSpan(
                              text: ' / ${service.duration} mins',
                              style: TextStyle(
                                color: Palette.green,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (!hidePrice) SizedBox(height: 0.5.h),
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
