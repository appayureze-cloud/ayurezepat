import 'package:doctro_patient/const/prefConstatnt.dart';
import 'package:doctro_patient/const/preference.dart';
import 'package:doctro_patient/model/v2/medicine/order_list_response.dart';
import 'package:doctro_patient/v2/utils/helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

import '../../../const/Palette.dart';
import 'order_item_card.dart';

class OrderCard extends HookWidget {
  final OrderListItem order;

  OrderCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Palette.lightGrey2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(2.h),
      ),
      margin: EdgeInsets.fromLTRB(3.w, 0, 3.w, 1.5.h),
      child: Padding(
        padding: EdgeInsets.only(top: 1.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 1.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 3.w),
              child: Row(
                children: [
                  RichText(
                    text: TextSpan(
                      text:
                          '${DateFormat("MMM dd, yyyy").format(DateTime.parse(order.createdAt!))}',
                      style: TextStyle(
                        color: Palette.black,
                        fontWeight: FontWeight.w600,
                        fontSize: 16.sp,
                      ),
                      children: [
                        TextSpan(
                          text:
                              '\t / Payment ${order.financialStatus!.toSentenceCase()}',
                          style: TextStyle(
                            color: Palette.primary,
                            fontWeight: FontWeight.w400,
                            fontSize: 14.5.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Spacer(),
                  Text(
                    '${SharedPreferenceHelper.getString(Preferences.currency_symbol)} ${order.totalPrice}',
                    style: TextStyle(
                      color: Palette.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 16.sp,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 1.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 3.w),
              child: RichText(
                text: TextSpan(
                  text: '${order.fulfillmentStatus ?? 'Pending'}'
                      .toSentenceCase(),
                  style: TextStyle(
                    color: Palette.green,
                    fontWeight: FontWeight.w600,
                    fontSize: 16.sp,
                  ),
                  children: [
                    // TextSpan(
                    //   text: ' in 3 - 5 days',
                    //   style: TextStyle(
                    //     color: Palette.black,
                    //     fontWeight: FontWeight.w400,
                    //     fontSize: 16.sp,
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 1.h),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(2.h),
                  bottomLeft: Radius.circular(2.h),
                ),
                color: Palette.white,
              ),
              child: Column(
                children: [
                  Divider(
                    height: 0.05.h,
                    thickness: 0.05.h,
                  ),
                  for (OrderedProduct product in (order.products ?? []))
                    OrderedItemCard(product: product),
                  Divider(),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 3.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total ${order.totalItemsOrdered ?? 0} items',
                          style: TextStyle(
                            color: Palette.grey,
                            fontWeight: FontWeight.w400,
                            fontSize: 16.sp,
                          ),
                        ),
                        Text(
                          'See all',
                          style: TextStyle(
                            color: Palette.black,
                            fontWeight: FontWeight.w600,
                            fontSize: 16.sp,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 1.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
