import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:sizer/sizer.dart';

import '../../../const/Palette.dart';
import '../../../const/prefConstatnt.dart';
import '../../../const/preference.dart';
import '../../../model/v2/medicine/order_list_response.dart';

class OrderedItemCard extends HookWidget {
  final OrderedProduct product;

  const OrderedItemCard({required this.product, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      // height: 12.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(3.w),
        border: Border.all(color: Palette.lightGrey),
        color: Palette.white,
      ),
      margin: EdgeInsets.all(2.w),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(2.w),
            child: CachedNetworkImage(
              imageUrl: product.image ?? '',
              fit: BoxFit.cover,
              height: 12.h,
              width: 25.w,
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
          SizedBox(width: 2.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 1.h),
                Text(
                  '${product.title}',
                  softWrap: true,
                  style: TextStyle(
                    color: Palette.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 15.sp,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text('${product.variantTitle}'.toUpperCase(),
                    style: TextStyle(
                      color: Palette.grey,
                      fontSize: 14.sp,
                    )),
                SizedBox(height: 1.h),
                Row(
                  children: [
                    Text(
                      '${SharedPreferenceHelper.getString(Preferences.currency_symbol)} ${product.price}',
                      style: TextStyle(
                        color: Palette.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 15.sp,
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Icon(
                      Icons.clear,
                      color: Palette.grey,
                      size: 4.w,
                    ),
                    SizedBox(width: 1.w),
                    Text(
                      '${product.quantity}',
                      style: TextStyle(
                        color: Palette.grey,
                        fontWeight: FontWeight.w600,
                        fontSize: 15.sp,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 1.h),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
