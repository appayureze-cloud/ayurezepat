import 'package:cached_network_image/cached_network_image.dart';
import 'package:doctro_patient/const/prefConstatnt.dart';
import 'package:doctro_patient/const/preference.dart';
import 'package:doctro_patient/model/v2/medicine/medicine_home_response.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:sizer/sizer.dart';

import '../../../const/Palette.dart';
import '../medicine/medicine_details.dart';

class HomeMedicineCard extends HookWidget {
  final PopularProducts product;

  const HomeMedicineCard({required this.product, super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
        height: 27.h,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(2.w),
          ),
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.all(2.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CachedNetworkImage(
                      imageUrl: '${product.image}',
                      fit: BoxFit.cover,
                      height: 35.w,
                      width: double.infinity,
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
                    SizedBox(height: 1.h),
                    Text(
                      '${product.title}',
                      style: TextStyle(
                        color: Palette.black,
                        fontSize: 16.sp,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Row(
                      children: [
                        Text(
                          '${SharedPreferenceHelper.getString(Preferences.currency_symbol)} ${product.price} ',
                          style: TextStyle(
                            color: Palette.primary,
                            fontSize: 15.sp,
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
                        SizedBox(width: 2.w),
                        Spacer(),
                        Icon(
                          Icons.add_circle_sharp,
                          color: Palette.primary,
                          size: 5.w,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if ((product.discountPercent ?? 0) > 0)
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
                      '${(product.discountPercent ?? 0).toStringAsFixed(2)}% off',
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
      ),
    );
  }
}
