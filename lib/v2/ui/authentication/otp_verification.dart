import 'package:doctro_patient/api/network_api.dart';
import 'package:doctro_patient/api/retrofit_Api.dart';
import 'package:doctro_patient/v2/ui/others/connectivity_responder.dart';
import 'package:doctro_patient/v2/ui/widgets/button_v2.dart';
import 'package:doctro_patient/v2/ui/widgets/header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:pinput/pinput.dart';
import 'package:sizer/sizer.dart';

import '../../../api/base_model.dart';
import '../../../api/server_error.dart';
import '../../../const/Palette.dart';
import '../../../model/v2/check_otp_model.dart';
import '../../../model/v2/resend_otp_model.dart';

class OTPVerification extends StatefulWidget {
  final int? id;

  OTPVerification({this.id});

  @override
  _OTPVerificationState createState() => _OTPVerificationState();
}

class _OTPVerificationState extends State<OTPVerification> {
  int? id = 0;
  bool loader = false;

  final TextEditingController _pinPutController = TextEditingController();
  final FocusNode _pinPutFocusNode = FocusNode();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    id = widget.id;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ConnectivityResponder(
      childContext: context,
      child: Scaffold(
        body: ModalProgressHUD(
          inAsyncCall: loader,
          opacity: 0.5,
          progressIndicator: SpinKitFadingCircle(
            color: Palette.primary,
            size: 3.h,
          ),
          child: GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(new FocusNode());
            },
            child: SingleChildScrollView(
              child: Center(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Header_v2(title: 'OTP Verification'),
                      SizedBox(height: 5.h),
                      Text(
                        "Enter your OTP code here",
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Pinput(
                            length: 4,
                            pinAnimationType: PinAnimationType.slide,
                            autofocus: true,
                            keyboardType: TextInputType.number,
                            focusNode: _pinPutFocusNode,
                            controller: _pinPutController,
                            submittedPinTheme: PinTheme().copyWith(
                                textStyle: TextStyle(
                                  fontSize: 16.sp,
                                  color: Palette.white,
                                ),
                                constraints: BoxConstraints(
                                  maxHeight: 5.h,
                                  minWidth: 5.h,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(3.w),
                                  color: Palette.primary,
                                  border: Border.all(
                                    color: Palette.primary.withOpacity(.2),
                                  ),
                                )),
                            focusedPinTheme: PinTheme().copyWith(
                                textStyle: TextStyle(fontSize: 16.sp),
                                constraints: BoxConstraints(
                                  maxHeight: 5.h,
                                  minWidth: 5.h,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(3.w),
                                  color: Palette.primary_bg,
                                  border: Border.all(
                                    color: Palette.primary.withOpacity(.2),
                                  ),
                                )),
                            followingPinTheme: PinTheme().copyWith(
                                textStyle: TextStyle(
                                  fontSize: 16.sp,
                                  color: Palette.white,
                                ),
                                constraints: BoxConstraints(
                                  maxHeight: 5.h,
                                  minWidth: 5.h,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(3.w),
                                  color: Palette.primary,
                                  border: Border.all(
                                    color: Palette.tealAccent.withOpacity(.2),
                                  ),
                                )),
                          ),
                        ],
                      ),
                      SizedBox(height: 3.h),
                      Container(
                        child: TweenAnimationBuilder(
                          tween: Tween(begin: 30.0, end: 0.0),
                          duration: Duration(seconds: 30),
                          builder: (_, dynamic value, child) => Text(
                            "00:${value.toInt()}",
                            style: TextStyle(
                              fontSize: 15.sp,
                              color: Palette.grey,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Column(
                        children: [
                          Text(
                            "Didn't received verification code?",
                            style: TextStyle(
                              fontSize: 15.sp,
                              color: Palette.dark_blue,
                            ),
                          ),
                          SizedBox(height: 1.h),
                          Column(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  callApiResendOtp();
                                },
                                child: Text(
                                  "Resend new OTP",
                                  style: TextStyle(
                                    color: Palette.primary,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16.sp,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 3.h),
                      ButtonV2(
                        label: 'Verify OTP',
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            callApiOTP();
                          } else {}
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<BaseModel<CheckOtpModel>> callApiOTP() async {
    CheckOtpModel response;
    Map<String, dynamic> body = {
      "user_id": id,
      "otp": _pinPutController.text,
    };
    setState(() {
      loader = true;
    });
    try {
      response =
          await RestClient(await RetroApi().dioData(context)).checkOtp(body);
      setState(() {
        loader = false;
        if (response.success == true) {
          Navigator.pushReplacementNamed(context, "SignIn");
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
      });
    } catch (error, stacktrace) {
      setState(() {
        loader = false;
      });
      // print("Exception occur: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  Future<BaseModel<ResendOtp>> callApiResendOtp() async {
    ResendOtp response;
    setState(() {
      loader = true;
    });
    try {
      response = await RestClient(RetroApi2().dioData2()).resendOtpRequest(id);
      setState(() {
        loader = false;
        if (response.success == true) {
          setState(() {
            Fluttertoast.showToast(
              msg: '${response.msg}',
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
            );
          });
        } else {
          setState(() {
            Fluttertoast.showToast(
              msg: '${response.msg}',
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
            );
          });
        }
      });
    } catch (error, stacktrace) {
      setState(() {
        loader = false;
      });
      // print("Exception occur: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }
}
