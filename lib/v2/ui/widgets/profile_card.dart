import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../const/Palette.dart';

class ProfileSectionCard extends StatelessWidget {
  final String title;
  final IconData? icon;
  final String? route;

  const ProfileSectionCard(
      {required this.title, this.route, this.icon, super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: route != null
          ? () {
              Navigator.pushNamed(context, '$route');
            }
          : null,
      child: Card(
        margin: EdgeInsets.symmetric(
          horizontal: 2.w,
          vertical: 0.5.h,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(2.w),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 3.w,
            vertical: 1.5.h,
          ),
          child: Row(
            children: [
              Icon(
                icon ?? Icons.settings,
                size: 20.sp,
                color: Palette.grey,
              ),
              SizedBox(width: 3.w),
              Text(
                '$title',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(width: 2.w),
              Spacer(),
              Icon(
                Icons.arrow_forward_ios,
                size: 16.sp,
                color: Palette.black,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
