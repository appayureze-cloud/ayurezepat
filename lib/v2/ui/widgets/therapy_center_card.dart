import 'package:cached_network_image/cached_network_image.dart';
import 'package:doctro_patient/model/v2/therapy_home_response.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:sizer/sizer.dart';

import '../../../const/Palette.dart';
import '../therapy/therapy_center_details.dart';

class TherapyCenterCard extends HookWidget {
  final Centers center;

  const TherapyCenterCard({required this.center, super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => TherapyCentersDetails(
                      center: center,
                    )));
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4.w),
        ),
        elevation: 2,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 2.w,
            vertical: 1.h,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(2.w),
                child: CachedNetworkImage(
                  imageUrl:
                      center.gallery!.isNotEmpty ? center.gallery!.first : '',
                  fit: BoxFit.cover,
                  height: 7.h,
                  width: 7.h,
                  placeholder: (context, url) => Center(
                    child: CircularProgressIndicator(),
                  ),
                  errorWidget: (context, url, error) => Center(
                    child: Image.asset(
                      "assets/images/NoImage.png",
                      fit: BoxFit.fitHeight,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${center.name}',
                      softWrap: true,
                      style: TextStyle(
                        color: Palette.black,
                        fontWeight: FontWeight.w600,
                        fontSize: 16.sp,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      '${center.address}',
                      softWrap: true,
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
                            initialRating: (center.rate ?? 0).toDouble(),
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
                          '(${center.review})',
                          style: TextStyle(
                            color: Palette.grey,
                            fontWeight: FontWeight.w500,
                            fontSize: 2.5.w,
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
