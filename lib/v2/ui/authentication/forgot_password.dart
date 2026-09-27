import 'package:doctro_patient/v2/ui/widgets/button_v2.dart';
import 'package:doctro_patient/v2/ui/widgets/custom_text_field.dart';
import 'package:doctro_patient/v2/ui/widgets/header.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
import 'package:sizer/sizer.dart';

import '../../../api/base_model.dart';
import '../../../api/network_api.dart';
import '../../../api/retrofit_Api.dart';
import '../../../api/server_error.dart';
import '../../../const/Palette.dart';
import '../../../model/v2/forgot_password_model.dart';
import '../others/connectivity_responder.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  TextEditingController email = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return ConnectivityResponder(
      childContext: context,
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: Scaffold(
          body: Form(
            key: _formKey,
            child: Center(
              child: Column(
                children: [
                  Header_v2(title: 'Forgot Password'),
                  SizedBox(height: 2.h),
                  Lottie.network(
                    'https://lottie.host/13066aca-8e51-4396-adf3-8eff4a86b2a6/7SuP7W6YJi.json',
                    height: 30.h,
                    fit: BoxFit.fitHeight,
                    alignment: Alignment.center,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    "Please enter your email address.You will receive a code to create a new password via email.",
                    style: TextStyle(
                      fontSize: 15.sp,
                      color: Palette.dark_blue,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 4.h),
                  CustomTextField(
                    textInputType: TextInputType.text,
                    controller: email,
                    hint: 'Email',
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
                  ),
                  SizedBox(height: 2.h),
                  ButtonV2(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        callForForgotPassword();
                      }
                    },
                    label: 'Reset Password',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<BaseModel<ForgotPassword>> callForForgotPassword() async {
    ForgotPassword response;
    Map<String, dynamic> body = {
      "email": email.text,
    };
    try {
      response =
          await RestClient(RetroApi2().dioData2()).forgotPasswordRequest(body);
      setState(() {
        Fluttertoast.showToast(
          msg: '${response.msg}',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Palette.blue,
          textColor: Palette.white,
        );
        email.clear();
      });
      Navigator.pushNamedAndRemoveUntil(context, 'SignIn', (_) => false);
    } catch (error, stacktrace) {
      // print("Exception occur: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }
}
