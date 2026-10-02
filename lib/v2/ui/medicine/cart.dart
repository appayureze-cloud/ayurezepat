import 'package:doctro_patient/api/network_api.dart';
import 'package:doctro_patient/api/retrofit_Api.dart';
import 'package:doctro_patient/const/prefConstatnt.dart';
import 'package:doctro_patient/const/preference.dart';
import 'package:doctro_patient/model/v2/medicine/cart_list_response.dart';
import 'package:doctro_patient/v2/ui/medicine/landing_screen.dart';
import 'package:doctro_patient/v2/ui/widgets/button_v2.dart';
import 'package:doctro_patient/v2/ui/widgets/no_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart' show SpinKitFadingCircle;
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart'
    show ModalProgressHUD;
import 'package:sizer/sizer.dart';

import '../../../const/Palette.dart';
import '../../utils/logger.dart';
import '../widgets/cart_item.dart';
import '../widgets/header.dart';

class Cart extends HookWidget {
  const Cart({super.key});

  @override
  Widget build(BuildContext context) {
    ValueNotifier<bool> loading = useState(true);
    ValueNotifier<List<CartItem>> items = useState([]);

    Future<void> fetchCartItems() async {
      loading.value = true;
      try {
        CartListResponse response =
            await RestClient(await RetroApi().dioData(context)).getCartItems();
        if (response.success == true && response.data != null) {
          items.value = response.data ?? [];
          loading.value = false;
        }
      } catch (error, stacktrace) {
        loading.value = false;
        logger.e("Exception occur: $error stackTrace: $stacktrace");
      }
    }

    useEffect(() {
      fetchCartItems();
    }, []);

    return Scaffold(
      body: ModalProgressHUD(
        inAsyncCall: loading.value,
        opacity: 0.5,
        progressIndicator: SpinKitFadingCircle(
          color: Palette.primary,
          size: 3.h,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Header_v2(
                title: 'Your Cart',
              ),
              SizedBox(height: 2.h),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 2.w,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (items.value.isNotEmpty)
                      Row(
                        children: [
                          Text(
                            '${items.value.length} item(s) in your cart',
                            style: TextStyle(
                              color: Palette.grey,
                              fontSize: 15.sp,
                            ),
                          ),
                          SizedBox(width: 3.w),
                          Spacer(),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MedicineLandingPage(
                                    index: 2,
                                  ),
                                ),
                              );
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.add_circle_outline_outlined,
                                  color: Palette.primary,
                                  size: 18.sp,
                                ),
                                SizedBox(width: 1.w),
                                Text(
                                  'Add more',
                                  style: TextStyle(
                                    color: Palette.primary,
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    if (items.value.isNotEmpty) SizedBox(height: 1.h),
                    for (CartItem item in items.value)
                      CartItemCard_v2(
                        item: item,
                        refresh: fetchCartItems,
                      ),
                    if (items.value.isNotEmpty) SizedBox(height: 2.h),
                    if (items.value.isEmpty) NoDataWidget(),
                    if (items.value.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Payment Summary',
                            style: TextStyle(
                              color: Palette.black,
                              fontSize: 17.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Order Total',
                                style: TextStyle(
                                  color: Palette.grey,
                                  fontSize: 15.sp,
                                ),
                              ),
                              Text(
                                '${SharedPreferenceHelper.getString(Preferences.currency_symbol)} ${items.value.fold(0.0, (sum, item) => sum + ((item.price ?? 0.0) * (item.quantity ?? 0)))}',
                                style: TextStyle(
                                  color: Palette.black,
                                  fontSize: 14.sp,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 1.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Item Discount',
                                style: TextStyle(
                                  color: Palette.grey,
                                  fontSize: 15.sp,
                                ),
                              ),
                              Text(
                                '${SharedPreferenceHelper.getString(Preferences.currency_symbol)} ${items.value.fold(0.0, (sum, item) => sum + (((item.originalPrice ?? 0.0) - (item.price ?? 0.0)) * (item.quantity ?? 0)))}',
                                style: TextStyle(
                                  color: Palette.black,
                                  fontSize: 14.sp,
                                ),
                              ),
                            ],
                          ),
                          // SizedBox(height: 1.h),
                          // Row(
                          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //   children: [
                          //     Text(
                          //       'Coupon Discount',
                          //       style: TextStyle(
                          //         color: Palette.grey,
                          //         fontSize: 15.sp,
                          //       ),
                          //     ),
                          //     Text(
                          //       '-${SharedPreferenceHelper.getString(Preferences.currency_symbol)} 50.00',
                          //       style: TextStyle(
                          //         color: Palette.black,
                          //         fontSize: 14.sp,
                          //       ),
                          //     ),
                          //   ],
                          // ),
                          // SizedBox(height: 1.h),
                          // Row(
                          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //   children: [
                          //     Text(
                          //       'Shipping',
                          //       style: TextStyle(
                          //         color: Palette.grey,
                          //         fontSize: 15.sp,
                          //       ),
                          //     ),
                          //     Text(
                          //       'Free',
                          //       style: TextStyle(
                          //         color: Palette.black,
                          //         fontSize: 14.sp,
                          //       ),
                          //     ),
                          //   ],
                          // ),
                          SizedBox(height: 2.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total',
                                style: TextStyle(
                                  color: Palette.black,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '${SharedPreferenceHelper.getString(Preferences.currency_symbol)} ${items.value.fold(0.0, (sum, item) => sum + ((item.price ?? 0.0) * (item.quantity ?? 0)))}',
                                style: TextStyle(
                                  color: Palette.black,
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    SizedBox(height: 2.h),
                    ButtonV2(
                      label: items.value.isNotEmpty
                          ? 'Checkout'
                          : 'Explore Products',
                      onPressed: () {
                        if (items.value.isNotEmpty)
                          Navigator.pushNamed(context, 'Checkout');
                        else
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MedicineLandingPage(
                                index: 2,
                              ),
                            ),
                          );
                      },
                    ),
                    SizedBox(height: 2.h),
                  ],
                ),
              ),
              SizedBox(height: 1.h),
            ],
          ),
        ),
      ),
    );
  }
}
