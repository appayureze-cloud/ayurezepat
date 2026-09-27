import 'package:doctro_patient/const/Palette.dart';
import 'package:doctro_patient/v2/ui/widgets/button_v2.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:sizer/sizer.dart';

class NoDataWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onRetry;

  const NoDataWidget({
    super.key,
    this.title = 'No Data Available',
    this.subtitle = 'We couldn\'t find any data to display right now.',
    this.icon = Icons.inbox_outlined,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 6.w),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 5.h, horizontal: 4.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.network(
                'https://lottie.host/bb8069d0-971b-46fc-b79b-2505690c7cd4/Ya8jljDG4r.json',
                height: 20.h,
                repeat: true,
              ),
              SizedBox(height: 2.h),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 1.h),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 15.sp,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              if (onRetry != null) ...[
                SizedBox(height: 3.h),
                SmallButton(
                  label: 'Retry',
                  onPressed: onRetry,
                  buttonColor: Palette.dark_grey,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class NoDataSectionWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onRetry;

  const NoDataSectionWidget({
    super.key,
    this.title = 'No Data Available',
    this.subtitle = 'We couldn\'t find any data to display right now.',
    this.icon = Icons.inbox_outlined,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 6.w),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 4.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.network(
                'https://lottie.host/2155ec18-5e76-49a5-ac98-084aa048ff2c/H1lLkpTAz6.json',
                height: 15.h,
                repeat: true,
              ),
              SizedBox(height: 2.h),
              Text(
                title,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w500,
                  color: Palette.grey,
                ),
                textAlign: TextAlign.center,
              ),
              if (onRetry != null) ...[
                SizedBox(height: 3.h),
                SmallButton(
                  label: 'Retry',
                  onPressed: onRetry,
                  buttonColor: Palette.dark_grey,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
