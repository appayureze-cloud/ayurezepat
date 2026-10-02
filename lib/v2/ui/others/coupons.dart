import 'package:doctro_patient/api/network_api.dart';
import 'package:doctro_patient/api/retrofit_Api.dart';
import 'package:doctro_patient/v2/ui/widgets/header.dart';
import 'package:doctro_patient/v2/ui/widgets/no_data.dart';
import 'package:doctro_patient/v2/utils/logger.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:sizer/sizer.dart';

import '../../../const/Palette.dart';
import '../../../const/prefConstatnt.dart';
import '../../../const/preference.dart';
import '../../../model/v2/apply_offer_model.dart';
import '../../../model/v2/display_offer_model.dart';

class CouponsScreen extends HookWidget {
  final String from;
  final DateTime date;
  final int? doctorId;
  final int? therapyCenterId;

  const CouponsScreen(
      {required this.from,
      required this.date,
      this.doctorId,
      this.therapyCenterId})
      : assert(
          ((doctorId != null) || (therapyCenterId != null)),
          'Either doctor or therapy center must be provided, but not both.',
        );

  @override
  Widget build(BuildContext context) {
    ValueNotifier<bool> loading = useState(true);

    ValueNotifier<List<Coupon>> offerList = useState([]);

    Future<void> fetchCoupons() async {
      loading.value = true;
      try {
        CouponsResponse response =
            await RestClient(await RetroApi().dioData(context)).fetchCoupons({
          'date': DateFormat("yyyy-MM-dd").format(date),
          'from': from,
          'doctor_id': doctorId,
          'therapy_center_id': therapyCenterId,
        });
        if (response.success == true) {
          offerList.value = response.data!;
          loading.value = false;
        }
      } catch (error, stacktrace) {
        loading.value = false;
        logger.e("Exception occur: $error stackTrace: $stacktrace");
      }
    }

    Future<bool> checkCoupon(Coupon coupon) async {
      loading.value = true;
      try {
        Map<String, dynamic> body = {
          "offer_code": coupon.offerCode,
          "date": DateFormat("yyyy-MM-dd").format(date),
          "from": from,
          'doctor_id': doctorId,
          'therapy_center_id': therapyCenterId,
        };
        ApplyOffer response =
            await RestClient(await RetroApi().dioData(context))
                .applyOfferRequest(body);
        if (response.success != true) {
          Fluttertoast.showToast(
            msg: '${response.msg}',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
          );
        }

        loading.value = false;
        return response.success == true;
      } catch (error, stacktrace) {
        loading.value = false;
        logger.e("Exception occur: $error stackTrace: $stacktrace");
      }
      return false;
    }

    useEffect(() {
      fetchCoupons();
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
            children: [
              Header_v2(title: 'Offers'),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 3.w,
                ),
                child: Column(
                  children: [
                    offerList.value.isNotEmpty
                        ? ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: offerList.value.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () async {
                                  if (await checkCoupon(
                                      offerList.value[index])) {
                                    Navigator.pop(
                                        context, offerList.value[index]);
                                  }
                                },
                                child: Column(
                                  children: [
                                    Container(
                                      margin: EdgeInsets.all(2.w),
                                      width: 100.w,
                                      color: index % 2 == 0
                                          ? Palette.light_blue
                                          : Palette.offer_card,
                                      child: Padding(
                                        padding:
                                            EdgeInsets.symmetric(vertical: 1.h),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  offerList.value[index].name!,
                                                  style: TextStyle(
                                                    fontSize: 18.sp,
                                                    color: index % 2 == 0
                                                        ? Palette.white
                                                        : Palette.light_blue,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            if (offerList.value[index]
                                                        .discountType ==
                                                    "amount" &&
                                                offerList.value[index].isFlat ==
                                                    0)
                                              Padding(
                                                padding:
                                                    EdgeInsets.only(top: 1.h),
                                                child: Center(
                                                  child: Text(
                                                    "FLAT" +
                                                        SharedPreferenceHelper
                                                                .getString(
                                                                    Preferences
                                                                        .currency_symbol)
                                                            .toString() +
                                                        offerList.value[index]
                                                            .discount
                                                            .toString(),
                                                    style: TextStyle(
                                                      color: Palette.dark_blue,
                                                      fontSize: 14.sp,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            if (offerList.value[index]
                                                        .discountType ==
                                                    "percentage" &&
                                                offerList.value[index].isFlat ==
                                                    0)
                                              Padding(
                                                padding:
                                                    EdgeInsets.only(top: 1.h),
                                                child: Center(
                                                  child: Text(
                                                    offerList.value[index]
                                                            .discount
                                                            .toString() +
                                                        '% ' +
                                                        "DISCOUNT",
                                                    style: TextStyle(
                                                        color:
                                                            Palette.dark_blue,
                                                        fontSize: 14.sp,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                              ),
                                            if (offerList.value[index]
                                                        .discountType ==
                                                    "amount" &&
                                                offerList.value[index].isFlat ==
                                                    1)
                                              Padding(
                                                padding:
                                                    EdgeInsets.only(top: 1.h),
                                                child: Center(
                                                  child: Text(
                                                    "FLAT" +
                                                        offerList.value[index]
                                                            .flatDiscount
                                                            .toString(),
                                                    style: TextStyle(
                                                      color: Palette.dark_blue,
                                                      fontSize: 14.sp,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            Padding(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 1.h),
                                              child: Column(
                                                children: [
                                                  DottedLine(
                                                    direction: Axis.horizontal,
                                                    lineLength: double.infinity,
                                                    lineThickness: 1.0,
                                                    dashLength: 3.0,
                                                    dashColor: index % 2 == 0
                                                        ? Palette.white
                                                        : Palette.light_blue,
                                                    dashRadius: 0.0,
                                                    dashGapLength: 1.0,
                                                    dashGapColor:
                                                        Palette.transparent,
                                                    dashGapRadius: 0.0,
                                                  )
                                                ],
                                              ),
                                            ),
                                            Column(
                                              children: [
                                                Text(
                                                  "Use Coupon code",
                                                  style: TextStyle(
                                                    fontSize: 15.sp,
                                                    color: index % 2 == 0
                                                        ? Palette.dark_white
                                                            .withOpacity(0.7)
                                                        : Palette.grey,
                                                  ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.all(1.h),
                                                  child: Align(
                                                    alignment: Alignment.center,
                                                    child: Container(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 8,
                                                              vertical: 4),
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5.w),
                                                        border: Border.all(
                                                            width: 1.0,
                                                            color: index % 2 ==
                                                                    0
                                                                ? Palette.white
                                                                : Palette.blue),
                                                      ),
                                                      child: SelectableText(
                                                        offerList.value[index]
                                                            .offerCode!,
                                                        cursorColor:
                                                            Palette.white,
                                                        style: TextStyle(
                                                          fontSize: 16.sp,
                                                          color: index % 2 == 0
                                                              ? Palette.white
                                                              : Palette
                                                                  .light_blue,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 1.h,
                                    )
                                  ],
                                ),
                              );
                            },
                          )
                        : NoDataWidget(
                            onRetry: fetchCoupons,
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
