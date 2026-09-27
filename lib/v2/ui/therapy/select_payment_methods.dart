import 'package:doctro_patient/const/prefConstatnt.dart';
import 'package:doctro_patient/const/preference.dart';
import 'package:doctro_patient/model/v2/display_offer_model.dart';
import 'package:doctro_patient/model/v2/make_therapy_booking_modal.dart';
import 'package:doctro_patient/v2/ui/widgets/button_v2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:sizer/sizer.dart';

import '../../../api/network_api.dart';
import '../../../api/retrofit_Api.dart';
import '../../../const/Palette.dart';
import '../../../model/v2/book_appointments_model.dart';
import '../../utils/logger.dart';
import '../appointment/payment_result.dart';
import '../widgets/header.dart';
import '../widgets/payment_card.dart';

class SelectTherapyPaymentMethods extends HookWidget {
  final MakeTherapyBookingModal details;
  final double fees;
  final double discount;
  final Coupon? coupon;

  SelectTherapyPaymentMethods(
      {required this.details,
      required this.fees,
      required this.discount,
      super.key,
      required this.coupon});

  final Razorpay razorpay = Razorpay();

  final String? razorpayKey =
      SharedPreferenceHelper.getString(Preferences.razor_key);
  final int? isRazorEnabled = SharedPreferenceHelper.getInt(Preferences.razor);
  final int? isCodEnabled = SharedPreferenceHelper.getInt(Preferences.cod);

  @override
  Widget build(BuildContext context) {
    ValueNotifier<String?> selectedPaymentType =
        useState(isRazorEnabled == 1 ? 'razorpay' : null);
    ValueNotifier<String?> _paymentToken = useState(null);
    final ValueNotifier<bool> loading = useState(false);

    Future<void> makeBooking() async {
      try {
        Map<String, dynamic> body = {
          "booking_for": details.bookingFor,
          "name": details.name,
          "age": details.age,
          "address": details.address.id,
          "phone_no": details.phone,
          "phone_code": details.phoneCode,
          "type": details.service != null ? "single" : "package",
          "date": DateFormat("yyyy-MM-dd").format(details.date),
          "time": DateFormat("hh:mm a").format(details.date),
          "duration": details.duration,
          "package_id": details.package?.id,
          "service_id": details.service?.id,
          "discount_id": coupon?.id,
          "discount_price": coupon == null ? 0 : discount,
          "amount": fees,
          "payment_type": selectedPaymentType.value,
          "payment_token":
              selectedPaymentType.value == 'cod' ? '' : _paymentToken.value,
          "payment_status": selectedPaymentType.value == 'cod' ? 0 : 1,
        };
        debugPrint('$body');
        loading.value = true;
        Preferences.onLoading(context);
        BookingResponse response =
            await RestClient(await RetroApi().dioData(context))
                .bookTherapySession(body);
        Fluttertoast.showToast(
          msg: '${response.msg}',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
        );
        Preferences.hideDialog(context);
        if (response.success == true)
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => PaymentResult(
                  from: 'therapy',
                  adetails: null,
                  tdetails: details,
                  bookingId: response.success == true ? response.data : null),
            ),
          );
      } catch (error, stacktrace) {
        Preferences.hideDialog(context);
        logger.e("Exception occur: $error stackTrace: $stacktrace");
      } finally {
        loading.value = false;
      }
    }

    void openCheckoutRazorPay() async {
      var map = {
        'key': SharedPreferenceHelper.getString(Preferences.razor_key),
        'amount': fees * 100,
        'name': 'Ayureze Healthcare',
        'currency': SharedPreferenceHelper.getString(Preferences.currency_code),
        'image': 'https://ayureze.org/images/upload/680ce4e79bca1.png',
        'description': '',
        'send_sms_hash': 'true',
        'prefill': {
          'contact': '${details.phone}',
          'email':
              '${SharedPreferenceHelper.getString(FirestoreConstants.email)}'
        },
      };
      var options = map;
      try {
        razorpay.open(options);
      } catch (e) {
        logger.e('Error: e');
      }
    }

    // RazorPay Success Method //
    void _handlePaymentSuccess(PaymentSuccessResponse response) {
      _paymentToken.value = response.paymentId;
      _paymentToken.value != null &&
              _paymentToken.value != "" &&
              _paymentToken.value!.isNotEmpty
          ? makeBooking()
          : Fluttertoast.showToast(
              msg: "Payment Failed", toastLength: Toast.LENGTH_SHORT);
    }

    // RazorPay Error Method //
    void _handlePaymentError(PaymentFailureResponse response) {}

    // RazorPay Wallet Method //
    void _handleExternalWallet(ExternalWalletResponse response) {}

    useEffect(() {
      razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
      razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
      razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    }, []);

    return SafeArea(
      child: ModalProgressHUD(
        inAsyncCall: loading.value,
        opacity: 0.5,
        progressIndicator: SpinKitFadingCircle(
          color: Palette.primary,
          size: 3.h,
        ),
        child: Scaffold(
          body: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Header_v2(
                title: 'Payment Method',
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 2.w,
                  vertical: 1.h,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 1.h),
                    Text(
                      'Select a Payment Method you want to use',
                      style: TextStyle(
                        color: Palette.black,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    if (isRazorEnabled == 1)
                      PaymentCard(
                        selectedPaymentType: selectedPaymentType,
                        title: 'Razorpay',
                        value: 'razorpay',
                      ),
                    if (isCodEnabled == 1)
                      PaymentCard(
                        selectedPaymentType: selectedPaymentType,
                        title: 'COD',
                        value: 'cod',
                      ),
                    SizedBox(height: 2.h),
                    ButtonV2(
                      label:
                          'Pay ${SharedPreferenceHelper.getString(Preferences.currency_symbol)} ${fees}',
                      onPressed: () {
                        if (selectedPaymentType.value != null) {
                          switch (selectedPaymentType.value) {
                            case 'razorpay':
                              {
                                openCheckoutRazorPay();
                                break;
                              }
                            case 'cod':
                              {
                                makeBooking();
                                break;
                              }
                          }
                        } else {
                          Fluttertoast.showToast(
                              msg: "Please select payment method",
                              toastLength: Toast.LENGTH_SHORT);
                        }
                        // Navigator.pushNamed(context, 'PaymentResult');
                      },
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
