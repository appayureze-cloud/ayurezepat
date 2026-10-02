import 'dart:convert';

import 'package:doctro_patient/model/v2/therapy_booking_details_response.dart';
import 'package:doctro_patient/model/v2/therapy_booking_list.dart';
import 'package:doctro_patient/v2/ui/others/add_review_screen.dart';
import 'package:doctro_patient/v2/ui/widgets/no_data.dart';
import 'package:doctro_patient/v2/ui/widgets/therapy_card.dart';
import 'package:doctro_patient/v2/ui/widgets/therapy_center_card.dart';
import 'package:doctro_patient/v2/ui/widgets/therapy_package_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:sizer/sizer.dart';

import '../../../api/network_api.dart';
import '../../../api/retrofit_Api.dart';
import '../../../const/Palette.dart';
import '../../../const/prefConstatnt.dart';
import '../../../const/preference.dart';
import '../../../model/v2/common_response.dart';
import '../../utils/helper.dart';
import '../../utils/logger.dart';
import '../others/html_content_page.dart';
import '../widgets/appointment_section_card.dart';
import '../widgets/button_v2.dart';
import '../widgets/header.dart';

class TherapyBookingDetailsScreen extends HookWidget {
  final TherapyBooking details;

  const TherapyBookingDetailsScreen({
    super.key,
    required this.details,
  });

  String get _dateTime {
    final DateTime startTime = DateFormat("yyyy-MM-dd hh:mm a")
        .parse('${details.date} ${details.time}');
    final DateTime endTime =
        startTime.add(Duration(minutes: details.duration ?? 0));
    return '${DateFormat("EEE, MMM dd\nhh:mm a").format(startTime)} to ${DateFormat("hh:mm a").format(endTime)}';
  }

  @override
  Widget build(BuildContext context) {
    ValueNotifier<TherapyBookingDetails?> booking = useState(null);
    ValueNotifier<String> reason = useState('');
    ValueNotifier<bool> loading = useState(true);
    ValueNotifier<List<String>> cancelReasons = useState([]);

    Future<void> fetchTherapyBookingDetails() async {
      try {
        loading.value = true;
        TherapyBookingDetailsResponse response =
            await RestClient(await RetroApi().dioData(context))
                .getTherapyBookingDetails(details.id!);
        if (response.success == true) {
          booking.value = response.data;
        }
      } catch (error, stacktrace) {
        logger.e("Exception occur: $error stackTrace: $stacktrace");
      } finally {
        loading.value = false;
      }
    }

    Future<void> fetchCancelReasons() async {
      try {
        var response = await RestClient(await RetroApi().dioData(context))
            .settingRequest();
        if (response.success == true) {
          var convertCancelReason =
              json.decode(response.data!.therapyCancelReason!);
          cancelReasons.value.clear();
          cancelReasons.value = List<String>.from(convertCancelReason);
        }
      } catch (error, stacktrace) {
        logger.e("Exception occur: $error stackTrace: $stacktrace");
      }
    }

    useEffect(() {
      () async {
        await Future.wait([fetchTherapyBookingDetails(), fetchCancelReasons()]);
      }();
    }, []);

    Widget paymentSection({
      required String title,
      required String value,
      Color? titleColor,
      Color? valueColor,
    }) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 1.h),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: 30.w,
              child: Text(
                '$title',
                style: TextStyle(
                  color: titleColor ?? Palette.black,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            SizedBox(width: 5.w),
            Flexible(
              child: Text(
                '$value',
                style: TextStyle(
                  color: valueColor ?? Palette.dark_grey,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.end,
              ),
            ),
          ],
        ),
      );
    }

    Future<void> cancelBookingApi() async {
      loading.value = true;
      Map<String, dynamic> body = {
        "booking_id": details.id,
        "cancel_reason": reason.value,
      };
      try {
        CommonResponse response =
            await RestClient(await RetroApi().dioData(context))
                .cancelTherapyBooking(body);
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
        loading.value = false;
      } catch (error, stacktrace) {
        loading.value = false;
        logger.e("Exception occur: $error stackTrace: $stacktrace");
      } finally {
        fetchTherapyBookingDetails();
      }
    }

    Future<void> cancelBooking() async {
      try {
        showDialog(
          context: context,
          builder: (context) {
            return StatefulBuilder(
              builder: (context, setState) {
                return AlertDialog(
                  insetPadding: EdgeInsets.all(20),
                  title: Text(
                    "Why do you cancel this Booking?",
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Palette.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  content: SizedBox(
                    width: 70.w,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: cancelReasons.value.length,
                      itemBuilder: (context, index) {
                        return RadioListTile(
                          value: cancelReasons.value[index],
                          groupValue: reason.value,
                          onChanged: (String? val) {
                            setState(() {
                              if (val != null) reason.value = val;
                            });
                          },
                          title: Text(
                            cancelReasons.value[index],
                            style: TextStyle(
                              fontSize: 15.sp,
                              color: Palette.black,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  actions: <Widget>[
                    OutlinedButton(
                      child: Text(
                        "No",
                      ),
                      onPressed: () {
                        setState(
                          () {
                            Navigator.of(context).pop();
                          },
                        );
                      },
                    ),
                    OutlinedButton(
                      child: Text(
                        "Yes",
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        cancelBookingApi();
                      },
                    ),
                  ],
                );
              },
            );
          },
        );
      } catch (e) {
        logger.e(e);
      }
    }

    return Scaffold(
      body: ModalProgressHUD(
        inAsyncCall: loading.value,
        opacity: 0.5,
        progressIndicator: SpinKitFadingCircle(
          color: Palette.primary,
          size: 3.h,
        ),
        child: loading.value
            ? SizedBox.shrink()
            : booking.value == null
                ? NoDataWidget()
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Header_v2(
                          title: 'Booking Details',
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 1.h, horizontal: 3.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TherapyCenterCard(
                                center: booking.value!.center!,
                              ),
                              SizedBox(height: 3.h),
                              AppointmentSectionCard(
                                icon: Icon(
                                  Icons.access_time_rounded,
                                  size: 6.w,
                                  color: Palette.black,
                                ),
                                title: 'Booking time',
                                subTitle: _dateTime,
                                description: ['completed', 'cancelled']
                                        .contains(booking.value?.bookingStatus)
                                    ? null
                                    : timeUntil(DateFormat("yyyy-MM-dd hh:mm a")
                                        .parse(
                                            '${details.date} ${details.time}')),
                              ),
                              SizedBox(height: 1.h),
                              AppointmentSectionCard(
                                icon: Icon(
                                  Icons.person_outline_sharp,
                                  size: 21.sp,
                                  color: Palette.black,
                                ),
                                title: 'Booked for',
                                subTitle:
                                    '${booking.value!.name} (${booking.value!.bookingFor!.toSentenceCase()})',
                                // titleColor: Palette.primary,
                                description:
                                    booking.value!.bookingStatus == 'pending'
                                        ? 'Active'
                                        : booking.value!.bookingStatus ==
                                                'cancelled'
                                            ? 'Cancelled'
                                            : booking.value!.bookingStatus!
                                                .toSentenceCase(),
                                descriptionColor:
                                    booking.value!.bookingStatus == 'pending'
                                        ? Palette.primary
                                        : booking.value!.bookingStatus ==
                                                'cancelled'
                                            ? Palette.red
                                            : Palette.green,
                              ),
                              SizedBox(height: 1.h),
                              if (booking.value!.service != null)
                                TherapyCard(
                                  service: booking.value!.service!,
                                  hidePrice: true,
                                ),
                              if (booking.value!.package != null)
                                TherapyPackageCard(
                                  package: booking.value!.package!,
                                  showOffer: false,
                                ),
                              SizedBox(height: 1.h),
                              AppointmentSectionCard(
                                icon: Icon(
                                  Icons.local_hospital_outlined,
                                  size: 6.w,
                                ),
                                title: 'Other Details',
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Divider(),
                                    paymentSection(
                                        title: 'Age',
                                        value: '${booking.value!.age!}'),
                                    paymentSection(
                                        title: 'Phone',
                                        value: booking.value!.phoneCode! +
                                            ' ' +
                                            booking.value!.phoneNo!),
                                    paymentSection(
                                        title: 'Address',
                                        value: booking
                                            .value!.booking_address!.address!
                                            .toSentenceCase()),
                                  ],
                                ),
                              ),
                              SizedBox(height: 1.h),
                              if (booking.value?.reviewDetails != null)
                                AppointmentSectionCard(
                                  icon: Icon(
                                    Icons.star,
                                    size: 21.sp,
                                    color: Palette.rating,
                                  ),
                                  title:
                                      'Reviewed on ${DateFormat('dd MMM, yyyy hh:mm a').format(DateTime.parse('${booking.value!.reviewDetails!.createdAt}'))}',
                                  subTitle:
                                      '${booking.value!.reviewDetails!.review}',
                                  titleColor: Palette.black,
                                  description:
                                      '${booking.value!.reviewDetails!.rate}',
                                  descriptionColor: Palette.purple,
                                ),
                              SizedBox(height: 3.h),
                              Text(
                                'Bill Details',
                                style: TextStyle(
                                  color: Palette.red,
                                  fontSize: 17.sp,
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                              SizedBox(height: 1.h),
                              paymentSection(
                                title: 'Consultation Fee',
                                value:
                                    '${SharedPreferenceHelper.getString(Preferences.currency_symbol)} ${booking.value!.amount! + (booking.value?.discountId != null ? (booking.value!.discountPrice ?? 0) : 0)}',
                              ),
                              if (booking.value?.discountId != null)
                                paymentSection(
                                  title: 'Discount',
                                  value:
                                      '${SharedPreferenceHelper.getString(Preferences.currency_symbol)} ${booking.value!.discountPrice ?? 0}',
                                ),
                              // SizedBox(height: 1.5.h),
                              // Row(
                              //   mainAxisAlignment: MainAxisAlignment.end,
                              //   children: [
                              //     Text(
                              //       'Service fee & Tax',
                              //       style: TextStyle(
                              //         color: Palette.black,
                              //         fontSize: 15.sp,
                              //         fontWeight: FontWeight.w400,
                              //       ),
                              //     ),
                              //     SizedBox(width: 2.w),
                              //     Text(
                              //       'Free',
                              //       style: TextStyle(
                              //         color: Palette.primary,
                              //         fontSize: 14.sp,
                              //         fontWeight: FontWeight.w400,
                              //       ),
                              //     ),
                              //     Spacer(),
                              //     Text(
                              //       '${SharedPreferenceHelper.getString(Preferences.currency_symbol)} 49',
                              //       style: TextStyle(
                              //         color: Palette.black,
                              //         fontSize: 15.sp,
                              //         fontWeight: FontWeight.w400,
                              //       ),
                              //     ),
                              //   ],
                              // ),
                              // SizedBox(height: 1.h),
                              // Text(
                              //   'We care for you & provide free appointment',
                              //   style: TextStyle(
                              //     color: Palette.primary,
                              //     fontSize: 14.sp,
                              //     fontWeight: FontWeight.w400,
                              //   ),
                              // ),
                              // SizedBox(height: 3.h),
                              Divider(),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 2.w),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${SharedPreferenceHelper.getString(Preferences.currency_symbol)} ${booking.value!.amount}',
                                          style: TextStyle(
                                            color: Palette.green,
                                            fontSize: 18.sp,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        if (booking.value?.cancelBy == null &&
                                            ['pending'].contains(
                                                booking.value?.bookingStatus))
                                          SizedBox(height: 1.h),
                                        if (booking.value?.cancelBy == null &&
                                            ['pending'].contains(
                                                booking.value?.bookingStatus))
                                          Text(
                                            'View Cancellation Policy',
                                            style: TextStyle(
                                              color: Palette.red,
                                              fontSize: 13.5.sp,
                                              fontWeight: FontWeight.w400,
                                              decoration:
                                                  TextDecoration.underline,
                                            ),
                                          ),
                                      ],
                                    ),
                                    if (booking.value?.cancelBy == null &&
                                        ['pending'].contains(
                                            booking.value?.bookingStatus))
                                      SizedBox(width: 2.w),
                                    if (booking.value?.cancelBy == null &&
                                        ['pending'].contains(
                                            booking.value?.bookingStatus))
                                      SizedBox(
                                        width: 50.w,
                                        child: Column(
                                          children: [
                                            ButtonV2(
                                              onPressed: () {
                                                reason.value = '';
                                                cancelBooking();
                                              },
                                              label: 'Cancel Booking',
                                              buttonColor: Palette.red,
                                            ),
                                            SizedBox(height: 1.h),
                                            GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        HtmlContentPage(
                                                      apiKey:
                                                          'cancellation_policy',
                                                      title:
                                                          'Cancellation Policy',
                                                    ),
                                                  ),
                                                );
                                              },
                                              child: Text(
                                                "Read Cancellation Policy",
                                                style: TextStyle(
                                                  fontSize: 14.sp,
                                                  color: Palette.red,
                                                  decoration:
                                                      TextDecoration.underline,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    if (booking.value?.rate == null &&
                                        booking.value?.reviewDetails == null &&
                                        ['completed'].contains(
                                            booking.value?.bookingStatus))
                                      SizedBox(
                                        width: 50.w,
                                        child: ButtonV2(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    ReviewScreen(
                                                  id: booking.value!.id!,
                                                  from: 'therapy',
                                                ),
                                              ),
                                            ).then((_) {
                                              fetchTherapyBookingDetails();
                                            });
                                          },
                                          label: 'Add Review',
                                          buttonColor: Palette.rating,
                                        ),
                                      ),
                                  ],
                                ),
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
