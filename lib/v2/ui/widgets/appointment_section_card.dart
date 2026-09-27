import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:sizer/sizer.dart';

import '../../../const/Palette.dart';

class AppointmentSectionCard extends HookWidget {
  final Widget icon;
  final String title;
  final String? subTitle;
  final String? description;
  final Widget? child;
  final Color? descriptionColor;
  final Color? titleColor;

  const AppointmentSectionCard({
    required this.icon,
    required this.title,
    this.subTitle,
    this.description,
    this.child,
    this.descriptionColor,
    this.titleColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        border: Border.all(
          color: Palette.grey.withValues(alpha: 0.2),
        ),
        borderRadius: BorderRadius.circular(3.w),
      ),
      child: Column(
        children: [
          Row(
            children: [
              icon,
              SizedBox(width: 2.w),
              Text(
                '$title',
                style: TextStyle(
                  color: titleColor ?? Palette.black,
                  fontSize: 15.5.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          if (subTitle != null) SizedBox(height: 1.5.h),
          if (subTitle != null)
            if (subTitle != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$subTitle',
                    style: TextStyle(
                      color: Palette.dark_grey,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (description != null) ...[
                    SizedBox(height: 0.5.h),
                    Text(
                      '$description',
                      style: TextStyle(
                        color: descriptionColor ?? Palette.primary,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
          if (child != null) SizedBox(height: 1.h),
          if (child != null) child!,
        ],
      ),
    );
  }
}
