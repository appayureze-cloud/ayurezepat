import 'package:doctro_patient/api/network_api.dart';
import 'package:doctro_patient/api/retrofit_Api.dart';
import 'package:doctro_patient/const/prefConstatnt.dart'
    show FirestoreConstants, Preferences;
import 'package:doctro_patient/const/preference.dart';
import 'package:doctro_patient/features/case/presentation/case_service.dart';
import 'package:doctro_patient/features/payments/domain/payment_repository.dart';
import 'package:doctro_patient/features/payments/presentation/payment_service.dart';
import 'package:doctro_patient/model/v2/common_response.dart';
import 'package:doctro_patient/model/v2/medicine/cart_list_response.dart';
import 'package:doctro_patient/v2/ui/address/add_address.dart' show AddLocation;
import 'package:doctro_patient/v2/ui/widgets/button_v2.dart';
import 'package:doctro_patient/v2/ui/widgets/cart_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart' show SpinKitFadingCircle;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart'
    show ModalProgressHUD;
import 'package:sizer/sizer.dart';

import '../../../const/Palette.dart';
import '../../../model/v2/show_address_model.dart'
    show Address, AddressListResponse;
import '../../utils/logger.dart';
import '../widgets/header.dart';
import '../widgets/payment_card.dart';

class Checkout extends HookWidget {
  Checkout({super.key});

  final int? isRazorEnabled = SharedPreferenceHelper.getInt(Preferences.razor);
  final int? isCodEnabled = SharedPreferenceHelper.getInt(Preferences.cod);

  @override
  Widget build(BuildContext context) {
    ValueNotifier<int?> selectedAddress = useState(null);
    ValueNotifier<bool> loading = useState(true);
    ValueNotifier<List<CartItem>> items = useState([]);
    ValueNotifier<List<Address>> addressList = useState([]);
    ValueNotifier<String?> selectedPaymentType =
        useState(isRazorEnabled == 1 ? 'razorpay' : null);

    Future<void> fetchAddresses() async {
      AddressListResponse response;
      try {
        response = await RestClient(await RetroApi().dioData(context))
            .showAddressRequest();
        addressList.value.clear();
        if (response.success == true) {
          addressList.value = List<Address>.from(response.data ?? []);
        }
      } catch (e) {
        logger.e('Error: $e');
      }
    }

    Future<void> fetchCartItems() async {
      try {
        CartListResponse response =
            await RestClient(await RetroApi().dioData(context)).getCartItems();
        if (response.success == true && response.data != null) {
          items.value = response.data ?? [];
        }
      } catch (error, stacktrace) {
        logger.e("Exception occur: $error stackTrace: $stacktrace");
      }
    }

    Future<void> makeOrder({String? paymentReference, String? caseId}) async {
      try {
        final dio = await RetroApi().dioData(context);
        final resolvedCaseId =
            caseId ?? (await CaseService.withDio(dio).ensureActiveCase()).id;

        Map<String, dynamic> body = {
          "case_id": resolvedCaseId,
          "line_items": List.generate(items.value.length, (i) {
            return {
              "variant_id": items.value[i].variantId!,
              "quantity": items.value[i].quantity!,
            };
          }),
          "address_id": selectedAddress.value,
          "discount_codes": [],
          "payment_mode": selectedPaymentType.value, // or "cod",
          "payment_reference": paymentReference,
        };
        Preferences.onLoading(context);
        CommonResponse response = await RestClient(dio).placeOrder(body);
        if (response.success == true) {
          Fluttertoast.showToast(
            msg: '${response.msg}',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
          );
          Preferences.hideDialog(context);
          Navigator.pushNamedAndRemoveUntil(context, 'Home', (_) => false);
        } else {
          Preferences.hideDialog(context);
          Fluttertoast.showToast(
            msg: "${response.msg}",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Palette.red,
            textColor: Palette.white,
          );
        }
      } catch (error, stacktrace) {
        Preferences.hideDialog(context);
        logger.e("Exception occur: $error stackTrace: $stacktrace");
        Fluttertoast.showToast(
            msg: "Order failed", toastLength: Toast.LENGTH_SHORT);
      }
    }

    Future<void> payWithRazorpay() async {
      loading.value = true;
      try {
        final dio = await RetroApi().dioData(context);
        final caseModel = await CaseService.withDio(dio).ensureActiveCase();
        final paymentReference = await PaymentService.withDio(dio).charge(
          purpose: PaymentRepository.purposeMedicineOrder,
          caseId: caseModel.id,
          reference: {
            'line_items': List.generate(items.value.length, (i) {
              return {
                "variant_id": items.value[i].variantId!,
                "quantity": items.value[i].quantity!,
              };
            }),
          },
          contactPhone: SharedPreferenceHelper.getString(Preferences.phone),
          contactEmail:
              SharedPreferenceHelper.getString(FirestoreConstants.email),
        );
        await makeOrder(
            paymentReference: paymentReference, caseId: caseModel.id);
      } on PaymentCancelledException {
        // no-op: user dismissed Razorpay.
      } catch (e) {
        logger.e('Payment failed: $e');
        Fluttertoast.showToast(
            msg: "Payment Failed", toastLength: Toast.LENGTH_SHORT);
      } finally {
        loading.value = false;
      }
    }

    useEffect(() {
      () async {
        loading.value = true;
        await Future.wait([fetchAddresses(), fetchCartItems()]);
        loading.value = false;
      }();
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
          child: loading.value
              ? SizedBox.shrink()
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Header_v2(
                      title: 'Checkout',
                    ),
                    SizedBox(height: 2.h),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 5.w,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                '${items.value.length} items in your cart',
                                style: TextStyle(
                                  color: Palette.grey,
                                  fontSize: 15.sp,
                                ),
                              ),
                              SizedBox(width: 3.w),
                              Spacer(),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'TOTAL',
                                    style: TextStyle(
                                      color: Palette.grey,
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                  SizedBox(height: 1.h),
                                  Text(
                                    '${SharedPreferenceHelper.getString(Preferences.currency_symbol)} ${items.value.fold(0.0, (sum, item) => sum + ((item.price ?? 0.0) * (item.quantity ?? 0)))}',
                                    style: TextStyle(
                                      color: Palette.black,
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          if (items.value.isNotEmpty) SizedBox(height: 1.h),
                          for (CartItem item in items.value)
                            CartItemCard_v2(
                              item: item,
                              refresh: fetchCartItems,
                              showActions: false,
                            ),
                          if (items.value.isNotEmpty) SizedBox(height: 2.h),
                          Text(
                            'Delivery Address',
                            style: TextStyle(
                              color: Palette.black,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 1.h),
                          for (Address ad in addressList.value)
                            AddressCard(
                              address: ad,
                              selectedAddress: selectedAddress,
                            ),
                          SizedBox(height: 1.h),
                          Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddLocation(
                                        currentLong: null, currentLat: null),
                                  ),
                                ).then((val) async {
                                  logger.i(val);
                                  loading.value = true;
                                  await fetchAddresses();
                                  loading.value = false;
                                });
                              },
                              child: Text(
                                'Add New Address',
                                style: TextStyle(
                                  color: Palette.primary,
                                  fontSize: 16.sp,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 2.h),
                          if (isRazorEnabled == 1)
                            PaymentCard(
                              selectedPaymentType: selectedPaymentType,
                              title: 'Razorpay',
                              value: 'razorpay',
                            ),
                          // if (isCodEnabled == 1)
                          PaymentCard(
                            selectedPaymentType: selectedPaymentType,
                            title: 'COD',
                            value: 'cod',
                          ),
                          SizedBox(height: 2.h),
                          ButtonV2(
                            label: 'Pay Now',
                            onPressed: () {
                              if (selectedPaymentType.value != null &&
                                  selectedAddress.value != null) {
                                switch (selectedPaymentType.value) {
                                  case 'razorpay':
                                    {
                                      payWithRazorpay();
                                      break;
                                    }
                                  case 'cod':
                                    {
                                      makeOrder();
                                      break;
                                    }
                                }
                              } else {
                                Fluttertoast.showToast(
                                    msg:
                                        "Please select payment method and address",
                                    toastLength: Toast.LENGTH_SHORT);
                              }
                            },
                          ),
                          SizedBox(height: 2.h),
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

class AddressCard extends HookWidget {
  final Address address;
  final ValueNotifier<int?> selectedAddress;

  AddressCard({
    required this.address,
    required this.selectedAddress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90.w,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2.w),
        border: Border.all(
          color: Palette.lightGrey,
        ),
      ),
      margin: EdgeInsets.symmetric(
        vertical: 0.75.h,
      ),
      padding: EdgeInsets.symmetric(vertical: 1.5.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Radio(
            activeColor: Palette.primary,
            value: address.id!,
            groupValue: selectedAddress.value,
            onChanged: (int? val) {
              if (val != null) {
                selectedAddress.value = val;
              }
            },
          ),
          SizedBox(width: 2.w),
          SizedBox(
            width: 60.w,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${address.label}',
                  style: TextStyle(
                    color: Palette.black,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  '${address.address}',
                  style: TextStyle(
                    color: Palette.grey,
                    fontSize: 16.sp,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 2.w),
        ],
      ),
    );
  }
}
