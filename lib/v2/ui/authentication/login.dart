import 'dart:developer';

import 'package:doctro_patient/FirebaseProviders/auth_provider.dart' as ap;
import 'package:doctro_patient/api/base_model.dart';
import 'package:doctro_patient/api/network_api.dart';
import 'package:doctro_patient/api/retrofit_Api.dart';
import 'package:doctro_patient/api/server_error.dart';
import 'package:doctro_patient/const/Palette.dart';
import 'package:doctro_patient/const/prefConstatnt.dart';
import 'package:doctro_patient/const/preference.dart';
import 'package:doctro_patient/model/v2/login_model.dart';
import 'package:doctro_patient/v2/ui/widgets/button_v2.dart';
import 'package:doctro_patient/v2/ui/widgets/custom_text_field.dart';
import 'package:doctro_patient/v2/utils/logger.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../others/connectivity_responder.dart';
import '../widgets/google_signin_button.dart';
import 'otp_verification.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  ap.AuthProvider? authProvider;

  Future<void> checkLoginStatus() async {
    getToken();
    await Future.delayed(Duration(milliseconds: 5));
    if (SharedPreferenceHelper.getBoolean(Preferences.is_logged_in) == true) {
      Navigator.pushReplacementNamed(context, "Home");
    }
  }

  @override
  Widget build(BuildContext context) {
    authProvider = Provider.of<ap.AuthProvider>(context);
    return ConnectivityResponder(
      childContext: context,
      child: Scaffold(
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  Container(
                    height: 100.h,
                    width: 100.w,
                    child: Stack(
                      children: [
                        Image.asset(
                          "assets/images/confident-doctor-half.png",
                          height: 50.h,
                          width: 100.w,
                          fit: BoxFit.cover,
                        ),
                        Positioned(
                          top: 35.h,
                          child: Container(
                            width: 100.w,
                            height: 100.h,
                            decoration: BoxDecoration(
                              color: Palette.white,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10.w),
                                topRight: Radius.circular(10.w),
                              ),
                            ),
                            child: ListView(
                              physics: NeverScrollableScrollPhysics(),
                              children: [
                                SizedBox(height: 2.h),
                                Column(
                                  children: [
                                    Text(
                                      "Welcome",
                                      // getTranslated(context,
                                      //         AppString.signIn_welcome)
                                      //     .toString(),
                                      style: TextStyle(
                                        fontSize: 21.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Palette.light_black,
                                      ),
                                    ),
                                    SizedBox(height: 1.h),
                                    Text(
                                      "Sign In",
                                      style: TextStyle(
                                        fontSize: 18.sp,
                                        color: Palette.dark_grey1,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 2.h),
                                Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 3.w),
                                  child: CustomTextField(
                                    controller: emailController,
                                    textInputType: TextInputType.text,
                                    validator: (String? value) {
                                      if (value!.isEmpty) {
                                        return "Please enter email";
                                      }
                                      if (!RegExp(
                                              r"^[a-zA-Z0-9.a-zA-Z0-9!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                          .hasMatch(value)) {
                                        return "Please enter valid email";
                                      }
                                      return null;
                                    },
                                    hint: 'Email',
                                  ),
                                ),
                                SizedBox(height: 1.h),
                                Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 3.w),
                                  child: CustomTextField(
                                    controller: passwordController,
                                    textInputType: TextInputType.text,
                                    hint: 'Password',
                                    isPassword: true,
                                    validator: (String? value) {
                                      if (value!.isEmpty) {
                                        return "Please enter password";
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                SizedBox(height: 3.h),
                                ButtonV2(
                                  label: "Sign In",
                                  onPressed: () {
                                    if (formKey.currentState!.validate()) {
                                      callForLogin();
                                    } else {
                                      // print('Not Login');
                                    }
                                  },
                                ),
                                SizedBox(height: 1.h),
                                GoogleSignInButton(),
                                SizedBox(height: 1.h),
                                TextButton(
                                  child: Text(
                                    "Forgot Password",
                                    style: TextStyle(
                                        fontSize: 16.sp,
                                        color: Palette.dark_grey),
                                    textAlign: TextAlign.center,
                                  ),
                                  onPressed: () {
                                    Navigator.pushNamed(
                                        context, 'ForgotPasswordScreen');
                                  },
                                ),
                                SizedBox(height: 1.h),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Don't have an account?",
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        color: Palette.dark_grey,
                                      ),
                                    ),
                                    SizedBox(width: 2.w),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.pushNamed(context, 'SignUp');
                                      },
                                      child: Text(
                                        "Sign Up",
                                        style: TextStyle(
                                          fontSize: 16.sp,
                                          color: Palette.blue,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> getToken() async {
    String? token = (await FirebaseMessaging.instance.getToken())!;
    if (token.isNotEmpty) {
      log("NotificationToken: $token");
      SharedPreferenceHelper.setString(
          Preferences.notificationRegisterKey, token);
    }
  }

  Future<BaseModel<LoginResponse>> callForLogin() async {
    LoginResponse response;
    Map<String, dynamic> body = {
      "email": emailController.text.toString(),
      "password": passwordController.text.toString(),
      "device_token":
          SharedPreferenceHelper.getString(Preferences.notificationRegisterKey),
    };

    Preferences.onLoading(context);
    try {
      response = await RestClient(RetroApi2().dioData2()).loginRequest(body);
      if (response.success == true) {
        Preferences.hideDialog(context);
        SharedPreferenceHelper.setString(
            FirestoreConstants.email, response.data!.email!);
        SharedPreferenceHelper.setString(
          FirestoreConstants.password,
          passwordController.text.toString(),
        );
        SharedPreferenceHelper.setString(
            FirestoreConstants.nickname, response.data!.name!);
        SharedPreferenceHelper.setString(
            FirestoreConstants.photoUrl, response.data!.fullImage!);
        SharedPreferenceHelper.setString(
            Preferences.image, response.data!.fullImage!);
        SharedPreferenceHelper.setString(
            Preferences.image, response.data!.fullImage!);
        SharedPreferenceHelper.setString(
            Preferences.userId, response.data!.id.toString());
        // OneSignal.login("${response.data!.id.toString()}");

        SharedPreferenceHelper.setString(
            Preferences.phone, response.data!.phone?.toString() ?? '+91');
        SharedPreferenceHelper.setString(Preferences.phoneCode,
            response.data!.phoneCode?.toString() ?? '+91');

        authProvider!.handleSignIn();

        var verify = response.data!.verify;
        var id = response.data!.id;

        verify != 0
            ? Navigator.pushReplacementNamed(context, "Home")
            : Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OTPVerification(id: id),
                ),
              );
        emailController.clear();
        passwordController.clear();
        if (response.token != null) {
          SharedPreferenceHelper.setString(
              Preferences.auth_token, response.token!);
        }

        if (response.refreshToken != null) {
          SharedPreferenceHelper.setString(
              Preferences.refresh_token, response.refreshToken!);
        }

        if (response.expiresIn != null) {
          SharedPreferenceHelper.setInt(
              Preferences.expiresIn, int.parse('${response.expiresIn}'));
          SharedPreferenceHelper.setInt(
              'token_saved_at', DateTime.now().millisecondsSinceEpoch);
        }

        SharedPreferenceHelper.setBoolean(Preferences.is_logged_in, true);

        Fluttertoast.showToast(
          msg: '${response.msg}',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Palette.blue,
          textColor: Palette.white,
        );
      } else {
        Preferences.hideDialog(context);
        Fluttertoast.showToast(
          msg: '${response.msg}',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Palette.blue,
          textColor: Palette.white,
        );
      }
    } catch (error, stacktrace) {
      Preferences.hideDialog(context);
      logger.e("Exception occur: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }
}
