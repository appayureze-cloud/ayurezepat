import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:doctro_patient/const/prefConstatnt.dart';
import 'package:doctro_patient/const/preference.dart';
import 'package:doctro_patient/model/v2/medicine/medicine_home_response.dart';
import 'package:doctro_patient/v2/ui/medicine/medicine_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:sizer/sizer.dart';

import '../../../const/Palette.dart';

class MedicineListCard extends HookWidget {
  final PopularProducts product;

  const MedicineListCard({required this.product, super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => MedicineDetailsScreen(
                      product: product,
                    )));
      },
      child: SizedBox(
        width: 45.w,
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3.w),
                color: Palette.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 6,
                    offset: Offset(0, 2), // changes the shadow position
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(3.w),
                      child: CachedNetworkImage(
                        imageUrl: '${product.image}',
                        fit: BoxFit.cover,
                        height: 45.w,
                        width: 45.w,
                        placeholder: (context, url) => Center(
                          child: CircularProgressIndicator(),
                        ),
                        errorWidget: (context, url, error) => Center(
                          child: Image.asset(
                            fit: BoxFit.cover,
                            height: 45.w,
                            width: 45.w,
                            "assets/images/NoImage.png",
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(1.2.h, 1.h, 0, 1.2.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${product.title}',
                          style: TextStyle(
                            color: Palette.black,
                            fontSize: 15.sp,
                          ),
                        ),
                        SizedBox(height: 0.8.h),
                        Row(
                          children: [
                            Text(
                              '${SharedPreferenceHelper.getString(Preferences.currency_symbol)} ${product.price}',
                              style: TextStyle(
                                color: Palette.black,
                                fontSize: 15.5.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if ((product.mrp ?? 0) > 0) SizedBox(width: 1.w),
                            if ((product.mrp ?? 0) > 0)
                              Text(
                                '${SharedPreferenceHelper.getString(Preferences.currency_symbol)} ${product.mrp}',
                                style: TextStyle(
                                  color: Palette.grey,
                                  fontSize: 14.sp,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            SizedBox(width: 1.w),
                            Spacer(),
                            Container(
                              padding: EdgeInsets.symmetric(
                                vertical: 0.5.h,
                                horizontal: 2.w,
                              ),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Palette.green,
                                borderRadius: BorderRadius.horizontal(
                                  left: Radius.circular(5.h),
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  SizedBox(width: 0.5.w),
                                  Icon(
                                    Icons.star,
                                    size: 17.sp,
                                    color: Palette.white,
                                  ),
                                  SizedBox(width: 1.w),
                                  Text(
                                    '${product.ratings}',
                                    style: TextStyle(
                                      color: Palette.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15.sp,
                                    ),
                                  ),
                                ],
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
            if ((product.discountPercent ?? 0) > 0)
              Positioned(
                top: 0,
                left: 0,
                child: ClipPath(
                  clipper: CornerTriangleClipper(),
                  child: Container(
                    width: 16.w,
                    height: 16.w,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(3.w),
                      ),
                    ),
                    child: Transform.rotate(
                      angle: -pi / 4,
                      child: Padding(
                        padding: EdgeInsets.only(
                          top: 3.5.w,
                          left: 2.w,
                        ),
                        child: Text(
                          '${(product.discountPercent ?? 0).toStringAsFixed(2)}% OFF',
                          // Can be any length
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12.5.sp,
                          ),
                        ),
                      ),
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

class CornerTriangleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height); // bottom left
    path.lineTo(size.width, 0); // top right
    path.lineTo(0, 0); // top left
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
