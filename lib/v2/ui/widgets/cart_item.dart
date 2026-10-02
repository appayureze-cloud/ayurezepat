import 'package:cached_network_image/cached_network_image.dart';
import 'package:doctro_patient/const/prefConstatnt.dart';
import 'package:doctro_patient/const/preference.dart';
import 'package:doctro_patient/model/v2/medicine/cart_list_response.dart';
import 'package:doctro_patient/v2/ui/medicine/cart_controller.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../const/Palette.dart';
import '../../utils/logger.dart';

class CartItemCard_v2 extends StatelessWidget {
  final CartItem item;
  final VoidCallback refresh;
  final bool showActions;

  CartItemCard_v2(
      {required this.item,
      required this.refresh,
      this.showActions = true,
      super.key});

  final CartController cartController = CartController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.5.h),
      child: SizedBox(
        height: 25.w,
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(2.w),
              child: CachedNetworkImage(
                imageUrl: item.imageUrl ?? '',
                fit: BoxFit.cover,
                width: 23.w,
                height: 25.w,
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
            SizedBox(
              width: showActions ? 51.w : 65.w,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Text(
                    '${item.title}',
                    style: TextStyle(
                      color: Palette.black,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    '${item.variant}',
                    style: TextStyle(
                      color: Palette.grey,
                      fontSize: 14.sp,
                    ),
                  ),
                  Spacer(),
                  RichText(
                    text: TextSpan(
                      text:
                          '${SharedPreferenceHelper.getString(Preferences.currency_symbol)} ${item.price} ',
                      style: TextStyle(
                        color: Palette.black,
                        fontSize: 17.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      children: [
                        TextSpan(
                          text: 'x ${item.quantity}',
                          style: TextStyle(
                            color: Palette.grey,
                            fontSize: 14.5.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (showActions)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        try {
                          bool result =
                              await cartController.updateCartDebounced(
                            context: context,
                            productId: item.productId!,
                            variantId: item.variantId!,
                            quantity: 0,
                            price: item.price!,
                            isRemove: true,
                          );
                          if (result) refresh();
                        } catch (e) {
                          logger.e(e);
                        }
                      },
                      child: Icon(
                        Icons.highlight_remove,
                        size: 18.sp,
                        color: Palette.grey,
                      ),
                    ),
                    Spacer(),
                    Container(
                      height: 3.h,
                      decoration: BoxDecoration(
                        color: Palette.grey.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(1.5.h),
                      ),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () async {
                              try {
                                bool result =
                                    await cartController.updateCartDebounced(
                                  context: context,
                                  productId: item.productId!,
                                  variantId: item.variantId!,
                                  quantity: ((item.quantity ?? 0) > 0)
                                      ? ((item.quantity ?? 0) + 1)
                                      : 0,
                                  price: item.price!,
                                  isRemove: true,
                                );
                                if (result) refresh();
                              } catch (e) {
                                logger.e(e);
                              }
                            },
                            child: Icon(
                              Icons.remove_circle_outlined,
                              size: 3.h,
                              color: Palette.primary,
                            ),
                          ),
                          Spacer(),
                          SizedBox(width: 2.w),
                          Text(
                            '${item.quantity}',
                            style: TextStyle(
                              color: Palette.black,
                              fontSize: 15.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 2.w),
                          Spacer(),
                          GestureDetector(
                            onTap: () async {
                              try {
                                bool result =
                                    await cartController.updateCartDebounced(
                                  context: context,
                                  productId: item.productId!,
                                  variantId: item.variantId!,
                                  quantity: (item.quantity ?? 0) + 1,
                                  price: item.price!,
                                  isRemove: false,
                                );
                                if (result) refresh();
                              } catch (e) {
                                logger.e(e);
                              }
                            },
                            child: Icon(
                              Icons.add_circle,
                              size: 3.h,
                              color: Palette.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
