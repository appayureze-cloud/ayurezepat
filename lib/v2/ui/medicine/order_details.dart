import 'package:doctro_patient/model/v2/medicine/order_details_response.dart';
import 'package:doctro_patient/model/v2/medicine/order_list_response.dart';
import 'package:doctro_patient/v2/ui/widgets/button_v2.dart';
import 'package:doctro_patient/v2/ui/widgets/header.dart';
import 'package:doctro_patient/v2/utils/helper.dart';
import 'package:easy_stepper/easy_stepper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

import '../../../api/network_api.dart';
import '../../../api/retrofit_Api.dart';
import '../../../const/Palette.dart';
import '../../../const/prefConstatnt.dart';
import '../../../const/preference.dart';
import '../../../model/v2/common_response.dart';
import '../../utils/logger.dart';
import '../others/html_content_page.dart';
import '../widgets/appointment_section_card.dart';
import '../widgets/order_item_card.dart';

class OrderDetails extends HookWidget {
  final int id;

  const OrderDetails({required this.id, super.key});

  @override
  Widget build(BuildContext context) {
    ValueNotifier<bool> loading = useState(true);
    ValueNotifier<Order?> details = useState(null);
    TextEditingController reasonController = useTextEditingController();

    Future<void> fetchOrderDetails() async {
      Preferences.onLoading(context);
      try {
        OrderDetailsResposne response =
            await RestClient(await RetroApi().dioData(context))
                .getOrderDetails(id);
        if (response.success == true && response.data != null) {
          details.value = response.data;
          loading.value = false;
        }
      } catch (error, stacktrace) {
        logger.e("Exception occur: $error stackTrace: $stacktrace");
      } finally {
        Preferences.hideDialog(context);
      }
    }

    Future<void> cancelOrder(String reason) async {
      Preferences.onLoading(context);
      Map<String, dynamic> body = {
        "cancel_reason": 'customer',
        "reason_note": reason,
      };
      try {
        CommonResponse response =
            await RestClient(await RetroApi().dioData(context))
                .cancelOrder(id, body);
        if (response.success == true) {
          Fluttertoast.showToast(
            msg: '${response.msg}',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
          );
        } else {
          Fluttertoast.showToast(
            msg: '${response.msg}',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
          );
        }
      } catch (error, stacktrace) {
        logger.e("Exception occur: $error stackTrace: $stacktrace");
      } finally {
        Preferences.hideDialog(context);
        fetchOrderDetails();
      }
    }

    void showCancelConfirmation() {
      reasonController.text = '';
      showDialog(
        context: context,
        barrierDismissible: false, // force user to pick an option
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'Cancel Order',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Palette.primary,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Are you sure you want to cancel this order?',
                  style: TextStyle(
                    fontSize: 16.sp,
                  ),
                ),
                SizedBox(height: 2.h),
                TextField(
                  controller: reasonController,
                  decoration: InputDecoration(
                    labelText: 'Enter Cancel Reason',
                    labelStyle: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // close dialog
                },
                child: Text(
                  'No',
                  style: TextStyle(
                    color: Palette.black,
                    fontSize: 15.sp,
                  ),
                ),
              ),
              SmallButton(
                width: 20.w,
                buttonColor: Palette.red,
                onPressed: () {
                  final String reason = reasonController.text.trim();

                  if (reason.isEmpty) {
                    // Optionally show error
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter a reason!')),
                    );
                    return;
                  }

                  Navigator.of(context).pop(); // close dialog

                  // 👉 Call your cancel function with reason:
                  cancelOrder(reason);
                },
                label: 'Cancel',
              ),
            ],
          );
        },
      );
    }

    useEffect(() {
      Future.delayed(Duration(milliseconds: 50), () {
        fetchOrderDetails();
      });
    }, []);

    return Scaffold(
      body: details.value == null || loading.value
          ? Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: fetchOrderDetails,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: Header_v2(title: 'Order Details')),
                  SliverToBoxAdapter(child: SizedBox(height: 2.h)),
                  SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 3.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RichText(
                                text: TextSpan(
                                  text: 'Order ID: \t',
                                  style: TextStyle(
                                    color: Palette.black,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16.sp,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: '${details.value!.id}',
                                      style: TextStyle(
                                        color: Palette.rating,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 2.h),
                              RichText(
                                text: TextSpan(
                                  text: 'Status: \t',
                                  style: TextStyle(
                                    color: Palette.black,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16.sp,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: '${details.value!.status}'
                                          .toSentenceCase(),
                                      style: TextStyle(
                                        color: _getStepColor(
                                            details.value!.status ?? 'pother'),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 2.h),
                              RichText(
                                text: TextSpan(
                                  text: 'Placed On: \t',
                                  style: TextStyle(
                                    color: Palette.grey,
                                    fontSize: 15.sp,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: DateFormat('MMMM dd, yyyy  hh:mm a')
                                          .format(DateTime.parse(
                                              '${details.value!.placedAt}')),
                                      style: TextStyle(
                                        color: Palette.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (details.value?.cancelledAt != null)
                                SizedBox(height: 2.h),
                              if (details.value?.cancelledAt != null)
                                RichText(
                                  text: TextSpan(
                                    text: 'Cancelled On: \t',
                                    style: TextStyle(
                                      color: Palette.grey,
                                      fontSize: 15.sp,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: DateFormat(
                                                'MMMM dd, yyyy  hh:mm a')
                                            .format(DateTime.parse(
                                                '${details.value!.cancelledAt}')),
                                        style: TextStyle(
                                          color: Palette.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              if (details.value?.cancelReason != null)
                                SizedBox(height: 2.h),
                              if (details.value?.cancelReason != null)
                                RichText(
                                  text: TextSpan(
                                    text: 'Cancelled Reason: \t',
                                    style: TextStyle(
                                      color: Palette.grey,
                                      fontSize: 15.sp,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: details.value?.cancelReason ==
                                                    'customer' &&
                                                details.value!
                                                        .cancelReasonNote !=
                                                    null
                                            ? details.value!.cancelReasonNote!
                                                .toSentenceCase()
                                            : (details.value!.cancelReason ??
                                                    'Others')
                                                .toSentenceCase(),
                                        style: TextStyle(
                                          color: Palette.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              if (details.value!.shippingAddress != null)
                                SizedBox(height: 2.h),
                              if (details.value!.shippingAddress != null)
                                AppointmentSectionCard(
                                  icon: Icon(
                                    Icons.location_on_outlined,
                                    size: 6.w,
                                    color: Palette.black,
                                  ),
                                  title: 'Shipping Address',
                                  subTitle:
                                      '${details.value!.shippingAddress!.address1! + ' ' + (details.value!.shippingAddress!.address2 ?? '')}',
                                ),
                              if (details.value!.billingAddress != null)
                                SizedBox(height: 1.h),
                              if (details.value!.billingAddress != null)
                                AppointmentSectionCard(
                                  icon: Icon(
                                    Icons.location_on_outlined,
                                    size: 6.w,
                                    color: Palette.black,
                                  ),
                                  title: 'Billing Address',
                                  subTitle:
                                      '${details.value!.billingAddress!.address1! + ' ' + (details.value!.billingAddress!.address2 ?? '')}',
                                ),
                              if (details.value?.financialStatus != 'pending' &&
                                  details.value?.paymentMethod != null)
                                SizedBox(height: 1.h),
                              if (details.value?.financialStatus != 'pending' &&
                                  details.value?.paymentMethod != null)
                                AppointmentSectionCard(
                                  icon: Icon(
                                    Icons.credit_card_sharp,
                                    size: 6.w,
                                    color: Palette.black,
                                  ),
                                  title: 'Order has been Paid',
                                  subTitle:
                                      'Online via ${details.value!.paymentMethod!.toSentenceCase()}',
                                ),
                              SizedBox(height: 2.h),
                              Text(
                                'Items ordered:',
                                style: TextStyle(
                                  color: Palette.black,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16.sp,
                                ),
                              ),
                              SizedBox(height: 1.h),
                              for (OrderedProduct product
                                  in (details.value!.products ?? []))
                                OrderedItemCard(product: product),
                              SizedBox(height: 3.h),
                              for (int i = 0;
                                  i <
                                          details.value!.fareSplitup!
                                              .toJson()
                                              .keys
                                              .length &&
                                      details.value!.fareSplitup!
                                              .toJson()
                                              .keys
                                              .elementAt(i) !=
                                          'currency';
                                  i++)
                                Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '${details.value!.fareSplitup!.toJson().keys.elementAt(i)}'
                                              .split('_')
                                              .join(' ')
                                              .toSentenceCase(),
                                          style: TextStyle(
                                            color: Palette.grey,
                                            fontSize: 16.sp,
                                          ),
                                        ),
                                        SizedBox(width: 2.w),
                                        Text(
                                          '${SharedPreferenceHelper.getString(Preferences.currency_symbol)} ${details.value!.fareSplitup!.toJson().values.elementAt(i)}',
                                          style: TextStyle(
                                            color: Palette.black,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16.sp,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Divider(),
                                  ],
                                ),
                              OrderStepper(
                                  activeStep: details.value!.activeStep!,
                                  tracking: details.value!.tracking ?? []),
                              if (details.value?.cancelledAt == null &&
                                  details.value?.status != 'fulfilled')
                                SizedBox(height: 3.h),
                              if (details.value?.cancelledAt == null &&
                                  details.value?.status != 'fulfilled')
                                ButtonV2(
                                  label: 'Cancel Order',
                                  buttonColor: Palette.red,
                                  onPressed: () {
                                    showCancelConfirmation();
                                  },
                                ),
                              if (details.value?.cancelledAt == null &&
                                  details.value?.status != 'fulfilled')
                                SizedBox(height: 1.h),
                              if (details.value?.cancelledAt == null &&
                                  details.value?.status != 'fulfilled')
                                Center(
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => HtmlContentPage(
                                            apiKey: 'cancellation_policy',
                                            title: 'Cancellation Policy',
                                          ),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      "Read Cancellation Policy",
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        color: Palette.red,
                                        decoration: TextDecoration.underline,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              SizedBox(height: 3.h),
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

Color _getStepColor(String status) {
  switch (status.toLowerCase()) {
    case 'cancelled':
      return Palette.red;
    case 'fulfilled':
    case 'delivered':
      return Palette.green;
    case 'processed':
    case 'paid':
      return Palette.blue;
    case 'in_transit':
    case 'out_for_delivery':
      return Palette.rating;
    default:
      return Palette.rating; // default for placed or unknown
  }
}

class OrderStepper extends StatelessWidget {
  final int activeStep;
  final List<Tracking> tracking;

  const OrderStepper({
    required this.activeStep,
    required this.tracking,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FittedBox(
        fit: BoxFit.fitWidth,
        child: EasyStepper(
          activeStep: activeStep,
          enableStepTapping: false,
          direction: Axis.horizontal,
          steppingEnabled: true,
          lineStyle: LineStyle(
            lineType: LineType.normal,
            finishedLineColor: Palette.green,
            unreachedLineColor: Palette.grey,
          ),
          finishedStepTextColor: Palette.green,
          unreachedStepTextColor: Palette.grey,
          internalPadding: 3.w,
          showLoadingAnimation: true,
          stepRadius: 3.w,
          activeStepBackgroundColor: Palette.rating,
          finishedStepBackgroundColor:
              activeStep == 4 ? Palette.red : Palette.green,
          unreachedStepBackgroundColor: Palette.lightGrey,
          padding: EdgeInsets.zero,
          steps: [
            for (int i = 0; i < tracking.length; i++)
              EasyStep(
                customStep: CircleAvatar(
                  radius: 2.w,
                  backgroundColor: Palette.white,
                  child: CircleAvatar(
                    radius: 1.w,
                    backgroundColor: activeStep == 4
                        ? Palette.red
                        : i == activeStep
                            ? _getStepColor(tracking[i].status!)
                            : i < activeStep
                                ? Palette.green
                                : Palette.black,
                  ),
                ),
                customTitle: Text(
                  '${tracking[i].step}',
                  style: TextStyle(
                    fontSize: i == activeStep ? 16.sp : 14.sp,
                    fontWeight: i == activeStep ? FontWeight.bold : null,
                    color: activeStep == 4
                        ? Palette.red
                        : i == activeStep
                            ? _getStepColor(tracking[i].status!)
                            : i < activeStep
                                ? Palette.green
                                : Palette.black,
                  ),
                ),
                topTitle: i % 2 == 0,
              ),
          ],
        ),
      ),
    );
  }
}
