import 'package:doctro_patient/api/base_model.dart';
import 'package:doctro_patient/api/network_api.dart';
import 'package:doctro_patient/api/retrofit_Api.dart';
import 'package:doctro_patient/api/server_error.dart';
import 'package:doctro_patient/const/Palette.dart';
import 'package:doctro_patient/model/v2/common_response.dart';
import 'package:doctro_patient/v2/ui/widgets/button_v2.dart';
import 'package:doctro_patient/v2/ui/widgets/custom_text_field.dart';
import 'package:doctro_patient/v2/ui/widgets/header.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';

class ChangePassword extends StatefulWidget {
  @override
  _ChangePasswordState createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  bool oldPassword = false;

  TextEditingController _oldPassword = TextEditingController();
  TextEditingController _newPassword = TextEditingController();
  TextEditingController _confirmPassword = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Header_v2(title: "Change Password"),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 3.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 2.h),

                      /// Old Password ///
                      Text(
                        "Current Password",
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Palette.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      CustomTextField(
                        controller: _oldPassword,
                        textInputType: TextInputType.text,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp('[a-zA-Z0-9@#\$&._~]'))
                        ],
                        isPassword: true,
                        hint: 'Enter current password',
                        validator: (String? value) {
                          if (value!.isEmpty) {
                            return "Please enter your current password";
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 2.h),

                      /// New Password ///
                      Text(
                        "New Password",
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Palette.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      CustomTextField(
                        controller: _newPassword,
                        textInputType: TextInputType.text,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp('[a-zA-Z0-9@#\$&._~]'))
                        ],
                        isPassword: true,
                        hint: 'Enter new password',
                        validator: (String? value) {
                          if (value!.isEmpty) {
                            return "Please enter new password";
                          } else if (value.length < 6) {
                            return "Password must be at least 6 characters";
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 2.h),

                      /// Confirm Password ///
                      Text(
                        "Confirm Password",
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Palette.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      CustomTextField(
                        controller: _confirmPassword,
                        textInputType: TextInputType.text,
                        isPassword: true,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp('[a-zA-Z0-9@#\$&._~]'))
                        ],
                        hint: 'Enter confirm password',
                        validator: (String? value) {
                          if (value!.isEmpty) {
                            return "Please enter confirm password";
                          } else if (_newPassword.text !=
                              _confirmPassword.text) {
                            return "Password and confirm password does not match";
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 3.h),

                      /// Button ///
                      ButtonV2(
                        label: "Update Password",
                        onPressed: () {
                          if (_formKey.currentState!.validate() &&
                              oldPassword == false) {
                            changepassword();
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
      ),
    );
  }

  Future<BaseModel<CommonResponse>> changepassword() async {
    CommonResponse response;
    Map<String, dynamic> body = {
      "old_password": _oldPassword.text.toString(),
      "password": _newPassword.text.toString(),
      "password_confirmation": _confirmPassword.text.toString(),
    };
    try {
      response = await RestClient(await RetroApi().dioData(context))
          .changePasswordRequest(body);
      if (response.success == true) {
        setState(
          () {
            _oldPassword.clear();
            _newPassword.clear();
            _confirmPassword.clear();
            Fluttertoast.showToast(
              msg: 'Change Password Successfully...',
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Palette.blue,
              textColor: Palette.white,
            );
          },
        );
      } else {}
    } catch (error, stacktrace) {
      // print("Exception occur: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }
}
