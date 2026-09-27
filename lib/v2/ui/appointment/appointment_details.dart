import 'dart:convert';
import 'dart:io' show Directory, File, HttpClient, Platform;

import 'package:doctro_patient/VideoCall/videoCall.dart';
import 'package:doctro_patient/model/v2/appointment_list_response.dart';
import 'package:doctro_patient/v2/ui/others/add_review_screen.dart';
import 'package:doctro_patient/v2/ui/widgets/no_data.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';

import '../../../api/network_api.dart';
import '../../../api/retrofit_Api.dart';
import '../../../const/Palette.dart';
import '../../../const/prefConstatnt.dart';
import '../../../const/preference.dart';
import '../../../model/v2/appointment_details_response.dart';
import '../../../model/v2/common_response.dart';
import '../../utils/helper.dart';
import '../../utils/logger.dart';
import '../../utils/notification_service.dart';
import '../others/html_content_page.dart';
import '../widgets/appointment_section_card.dart';
import '../widgets/button_v2.dart';
import '../widgets/doctor_details_card.dart';
import '../widgets/header.dart';

class AppointmentDetails extends HookWidget {
  final AppointmentListItemModal details;

  const AppointmentDetails({
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
    ValueNotifier<Appointment?> appointment = useState(null);
    ValueNotifier<String> reason = useState('');
    ValueNotifier<bool> loading = useState(true);
    ValueNotifier<List<String>> cancelReasons = useState([]);

    Future<void> fetchAppointmentDetails() async {
      loading.value = true;
      try {
        AppointmentDetailsResponse response =
            await RestClient(await RetroApi().dioData(context))
                .getAppointmentDetails(details.id!);
        if (response.success == true) {
          appointment.value = response.data;
          loading.value = false;
        }
      } catch (error, stacktrace) {
        loading.value = false;
        logger.e("Exception occur: $error stackTrace: $stacktrace");
      }
    }

    Future<void> fetchCancelReasons() async {
      loading.value = true;
      try {
        var response = await RestClient(await RetroApi().dioData(context))
            .settingRequest();
        if (response.success == true) {
          var convertCancelReason = json.decode(response.data!.cancelReason!);
          cancelReasons.value.clear();
          cancelReasons.value = List<String>.from(convertCancelReason);
        }
        loading.value = false;
      } catch (error, stacktrace) {
        loading.value = false;
        logger.e("Exception occur: $error stackTrace: $stacktrace");
      }
    }

    Future<String> downloadFile(String url, String fileName, String dir) async {
      HttpClient httpClient = new HttpClient();
      File file;
      String filePath = '';
      String myUrl = '';
      try {
        myUrl = url;
        var request = await httpClient.getUrl(Uri.parse(myUrl));
        var response = await request.close();
        if (response.statusCode == 200) {
          var bytes = await consolidateHttpClientResponseBytes(response);
          filePath = '$dir/$fileName';
          file = File(filePath);
          await file.writeAsBytes(bytes);
          await NotificationService.showDownloadCompleteNotification(filePath);
        } else
          filePath = 'Error code: ' + response.statusCode.toString();
      } catch (ex) {
        filePath = 'Can not fetch url';
      }
      return filePath;
    }

    void _downloadPrescription() async {
      if (appointment.value?.prescription?.pdfPath == null) {
        Fluttertoast.showToast(
          msg: "Invalid prescription!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
        return;
      }
      // Request storage permission if denied
      if (await Permission.storage.isDenied) {
        await Permission.storage.request();
      }

      // Determine platform and get appropriate directory
      Directory? baseDir;
      if (Platform.isAndroid) {
        baseDir = await getExternalStorageDirectory();
      } else if (Platform.isIOS) {
        baseDir = await getApplicationDocumentsDirectory();
      }

      if (baseDir == null) {
        Fluttertoast.showToast(
          msg: "Unable to access storage directory.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
        return;
      }

      // Prepare download path
      final pathSegments = baseDir.path.split("/");
      final rootPath = pathSegments.take(4).join("/");
      final outputDirectory = '$rootPath/Download/Ayureze';

      // Create the download directory if it doesn't exist
      await Directory(outputDirectory).create(recursive: true);

      // Generate file name with timestamp
      final currentTime = DateTime.now().millisecondsSinceEpoch.toString();
      final fileName = 'Ayureze-$currentTime.pdf';

      // Start downloading file
      await downloadFile('${appointment.value!.prescription!.pdfPath!}',
              fileName, outputDirectory)
          .whenComplete(() {
        Fluttertoast.showToast(
          msg: "Download completed!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
      });
    }

    useEffect(() {
      fetchAppointmentDetails();
      fetchCancelReasons();
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

    Future<void> cancelAppointmentApi() async {
      loading.value = true;
      Map<String, dynamic> body = {
        "appointment_id": details.id,
        "cancel_reason": reason.value,
      };
      try {
        CommonResponse response =
            await RestClient(await RetroApi().dioData(context))
                .cancelAppointmentRequest(body);
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
        fetchAppointmentDetails();
      }
    }

    Future<void> cancelAppointment() async {
      try {
        showDialog(
          context: context,
          builder: (context) {
            return StatefulBuilder(
              builder: (context, setState) {
                return AlertDialog(
                  insetPadding: EdgeInsets.all(20),
                  title: Text(
                    "Why do you cancel an Appointment?",
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
                        cancelAppointmentApi();
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
        child: loading.value || appointment.value == null
            ? NoDataWidget(
                onRetry: fetchAppointmentDetails,
              )
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Header_v2(
                      title: 'Appointment Details',
                    ),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 1.h, horizontal: 3.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DoctorDetailsCard(
                            doctor: appointment.value!.doctor!,
                          ),
                          SizedBox(height: 3.h),
                          AppointmentSectionCard(
                            icon: Icon(
                              Icons.access_time_rounded,
                              size: 6.w,
                              color: Palette.black,
                            ),
                            title: 'Appointment time',
                            subTitle: _dateTime,
                            description: appointment.value!.appointmentStatus ==
                                        'approve' ||
                                    appointment.value!.appointmentStatus ==
                                        'pending'
                                ? timeUntil(DateFormat("yyyy-MM-dd hh:mm a")
                                    .parse('${details.date} ${details.time}'))
                                : null,
                          ),
                          SizedBox(height: 1.h),
                          AppointmentSectionCard(
                            icon: SvgPicture.asset(
                              'assets/icons/clinic.svg',
                              height: 6.w,
                              width: 6.w,
                            ),
                            title: 'Clinic Details',
                            subTitle:
                                '${appointment.value!.hospital!.hospitalName}\n${appointment.value!.hospital!.address}',
                          ),
                          SizedBox(height: 1.h),
                          AppointmentSectionCard(
                            icon: Icon(
                              Icons.person_outline_sharp,
                              size: 21.sp,
                              color: Palette.black,
                            ),
                            title:
                                '${appointment.value!.appointmentType!.toSentenceCase()} Appointment for',
                            subTitle:
                                '${appointment.value!.patientName} (${appointment.value!.appointmentFor!.toSentenceCase()})',
                            // titleColor: Palette.primary,
                            description: appointment.value!.appointmentStatus ==
                                    'approve'
                                ? 'Active'
                                : appointment.value!.appointmentStatus ==
                                        'cancel'
                                    ? 'Cancelled'
                                    : appointment.value!.appointmentStatus!
                                        .toSentenceCase(),
                            descriptionColor:
                                appointment.value!.appointmentStatus ==
                                        'approve'
                                    ? Palette.primary
                                    : appointment.value!.appointmentStatus ==
                                            'cancel'
                                        ? Palette.red
                                        : Palette.rating,
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
                                    title: 'Patient Age',
                                    value: '${appointment.value!.age!}'),
                                paymentSection(
                                    title: 'Phone',
                                    value: appointment.value!.phoneCode! +
                                        ' ' +
                                        appointment.value!.phoneNo!),
                                paymentSection(
                                    title: 'Illness',
                                    value: appointment
                                        .value!.illnessInformation!
                                        .toSentenceCase()),
                                paymentSection(
                                    title: 'Side Effects',
                                    value: appointment.value!.drugEffect!
                                        .toSentenceCase()),
                                paymentSection(
                                    title: 'Note',
                                    value: appointment.value!.note
                                            ?.toSentenceCase() ??
                                        '-'),
                                paymentSection(
                                    title: 'Address',
                                    value: appointment.value!.patientAddress!
                                        .toSentenceCase()),
                              ],
                            ),
                          ),
                          SizedBox(height: 1.h),
                          if (appointment.value?.reviewDetails != null)
                            AppointmentSectionCard(
                              icon: Icon(
                                Icons.star,
                                size: 21.sp,
                                color: Palette.rating,
                              ),
                              title:
                                  'Reviewed on ${DateFormat('dd MMM, yyyy hh:mm a').format(DateTime.parse('${appointment.value!.reviewDetails!.createdAt}'))}',
                              subTitle:
                                  '${appointment.value!.reviewDetails!.review}',
                              titleColor: Palette.black,
                              description:
                                  '${appointment.value!.reviewDetails!.rate}',
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
                                '${SharedPreferenceHelper.getString(Preferences.currency_symbol)} ${double.parse(appointment.value!.amount!) + (appointment.value?.discountId != null ? (appointment.value!.discountPrice ?? 0) : 0)}',
                          ),
                          if (appointment.value?.discountId != null)
                            paymentSection(
                              title: 'Discount',
                              value:
                                  '${SharedPreferenceHelper.getString(Preferences.currency_symbol)} ${appointment.value!.discountPrice ?? 0}',
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${SharedPreferenceHelper.getString(Preferences.currency_symbol)} ${appointment.value!.amount}',
                                      style: TextStyle(
                                        color: Palette.green,
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    if (appointment.value?.cancelBy == null &&
                                        ['approve', 'pending'].contains(
                                            appointment
                                                .value?.appointmentStatus))
                                      SizedBox(height: 1.h),
                                    if (appointment.value?.cancelBy == null &&
                                        ['approve', 'pending'].contains(
                                            appointment
                                                .value?.appointmentStatus))
                                      Text(
                                        'View Cancellation Policy',
                                        style: TextStyle(
                                          color: Palette.red,
                                          fontSize: 13.5.sp,
                                          fontWeight: FontWeight.w400,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                  ],
                                ),
                                if (appointment.value?.cancelBy == null &&
                                    ['approve', 'pending'].contains(
                                        appointment.value?.appointmentStatus))
                                  SizedBox(width: 2.w),
                                if (appointment.value?.cancelBy == null &&
                                    ['approve', 'pending'].contains(
                                        appointment.value?.appointmentStatus))
                                  SizedBox(
                                    width: 50.w,
                                    child: Column(
                                      children: [
                                        ButtonV2(
                                          onPressed: () {
                                            reason.value = '';
                                            cancelAppointment();
                                          },
                                          label: 'Cancel Appointment',
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
                                              decoration:
                                                  TextDecoration.underline,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                if (appointment.value?.review == null &&
                                    appointment.value?.reviewDetails == null &&
                                    ['completed'].contains(
                                        appointment.value?.appointmentStatus))
                                  SizedBox(
                                    width: 50.w,
                                    child: ButtonV2(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ReviewScreen(
                                              id: appointment.value!.id!,
                                              from: 'appointment',
                                            ),
                                          ),
                                        ).then((_) {
                                          fetchAppointmentDetails();
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
                          if (appointment.value?.prescription != null)
                            Center(
                              child: SizedBox(
                                width: 50.w,
                                child: ButtonV2(
                                  onPressed: () {
                                    _downloadPrescription();
                                  },
                                  label: 'Download Prescription',
                                  buttonColor: Palette.blue,
                                ),
                              ),
                            ),
                          if (['approve']
                              .contains(appointment.value?.appointmentStatus))
                            Center(
                              child: SizedBox(
                                width: 50.w,
                                child: ButtonV2(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => VideoCall(
                                          doctorId: appointment.value!.doctorId,
                                        ),
                                      ),
                                    ).then((_) {
                                      fetchAppointmentDetails();
                                    });
                                  },
                                  label: 'Call Now',
                                  buttonColor: Palette.green,
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
      ),
    );
  }
}
