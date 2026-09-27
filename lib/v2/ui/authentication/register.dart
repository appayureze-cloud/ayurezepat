import 'package:country_picker/country_picker.dart';
import 'package:doctro_patient/api/network_api.dart';
import 'package:doctro_patient/api/retrofit_Api.dart';
import 'package:doctro_patient/v2/ui/widgets/button_v2.dart';
import 'package:doctro_patient/v2/ui/widgets/custom_text_field.dart';
import 'package:doctro_patient/v2/ui/widgets/header.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

import '../../../api/base_model.dart';
import '../../../api/server_error.dart';
import '../../../const/Palette.dart';
import '../../../const/prefConstatnt.dart';
import '../../../model/v2/register_model.dart';
import '../../utils/helper.dart';
import '../../utils/logger.dart';
import '../others/connectivity_responder.dart';
import '../others/html_content_page.dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  TextEditingController _name = TextEditingController();
  TextEditingController _email = TextEditingController();
  TextEditingController _phone = TextEditingController();
  TextEditingController _phoneCode = TextEditingController(text: '+91');
  TextEditingController _dob = TextEditingController();
  TextEditingController _password = TextEditingController();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  DateTime? _selectedDate;
  List<String> gender = ["Male", "Female"];
  String? _selectGender;
  int? id;
  int? verify;

  String newDateApiPass = "";
  var temp;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ConnectivityResponder(
      childContext: context,
      child: Scaffold(
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: SingleChildScrollView(
            child: Center(
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    Header_v2(title: "Create an Account"),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 3.w),
                      child: Column(
                        children: [
                          Column(
                            children: [
                              SizedBox(height: 2.h),

                              /// Name ///
                              CustomTextField(
                                controller: _name,
                                textInputType: TextInputType.text,
                                textCapitalization: TextCapitalization.words,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp('[a-zA-Z ]'))
                                ],
                                hint: 'User Name',
                                validator: (String? value) {
                                  value!.trim();
                                  if (value.isEmpty) {
                                    return "Please enter name";
                                  } else if (value.trim().length < 1) {
                                    return "Please enter valid name";
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 1.5.h),

                              /// Email ///
                              CustomTextField(
                                controller: _email,
                                textInputType: TextInputType.text,
                                hint: 'Email address',
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
                              SizedBox(height: 1.5.h),

                              /// Phone No. ///
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 20.w,
                                    child: CustomTextField(
                                      textInputType: TextInputType.phone,
                                      readOnly: true,
                                      controller: _phoneCode,
                                      hint: '+91',
                                      onTap: () {
                                        showCountryPicker(
                                          context: context,
                                          exclude: <String>['KN', 'MF'],
                                          showPhoneCode: true,
                                          onSelect: (Country country) {
                                            _phoneCode.text =
                                                "+" + country.phoneCode;
                                          },
                                          countryListTheme:
                                              CountryListThemeData(
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(4.w),
                                              topRight: Radius.circular(4.w),
                                            ),
                                            inputDecoration: InputDecoration(
                                              labelText: "Search",
                                              hintText:
                                                  "Start typing to search",
                                              prefixIcon: Icon(
                                                Icons.search,
                                                size: 21.sp,
                                              ),
                                              border: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Palette.grey
                                                      .withOpacity(0.2),
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  SizedBox(width: 3.w),
                                  SizedBox(
                                    width: 67.w,
                                    child: CustomTextField(
                                      controller: _phone,
                                      textInputType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(
                                          RegExp('[0-9]'),
                                        ),
                                        LengthLimitingTextInputFormatter(10)
                                      ],
                                      hint: "Phone Number",
                                      validator: (String? value) {
                                        if (value!.isEmpty) {
                                          return "Please enter phone";
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 1.5.h),

                              /// Birth Date ///
                              CustomTextField(
                                textCapitalization: TextCapitalization.words,
                                controller: _dob,
                                hint: "Select Birth Date",
                                validator: (String? value) {
                                  if (value!.isEmpty) {
                                    return "Please select birth date";
                                  }
                                  return null;
                                },
                                onTap: () {
                                  _selectDate(context);
                                },
                              ),
                              SizedBox(height: 1.5.h),

                              /// Gender ///
                              CustomDropdown<String>(
                                value: _selectGender,
                                hint: 'Select Gender',
                                onChanged: (dynamic newValue) {
                                  setState(
                                    () {
                                      _selectGender = newValue;
                                    },
                                  );
                                },
                                validator: (dynamic value) => value == null
                                    ? "Please select gender"
                                    : null,
                                items: gender,
                              ),
                              SizedBox(height: 1.5.h),

                              /// Password ///
                              CustomTextField(
                                controller: _password,
                                textInputType: TextInputType.text,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp('[a-zA-Z0-9@#\$&._~]'))
                                ],
                                hint: 'Password',
                                isPassword: true,
                                validator: (String? value) {
                                  if (value!.isEmpty) {
                                    return "Please enter password";
                                  }
                                  if (value.length < 6) {
                                    return "Please enter at least 6 character password";
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 1.5.h),
                            ],
                          ),
                          ButtonV2(
                            onPressed: () {
                              if (formKey.currentState!.validate()) {
                                callApiRegister();
                              } else {
                                logger.e("Unsuccessful");
                              }
                            },
                            label: 'Sign Up',
                          ),
                          SizedBox(height: 1.h),
                          RichText(
                            text: TextSpan(
                              text:
                                  "By continuing sign up, you agree to the following ",
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Palette.dark_blue,
                              ),
                              children: [
                                TextSpan(
                                  text: "Terms & Conditions",
                                  style: TextStyle(
                                    color: Palette.primary,
                                    decoration: TextDecoration.underline,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      // Handle the tap here, e.g., navigate to another screen
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => HtmlContentPage(
                                            apiKey: 'terms_and_conditions',
                                            title: 'Terms & Conditions',
                                          ),
                                        ),
                                      );
                                    },
                                ),
                                TextSpan(
                                  text: " without reservation.",
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 3.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Already have an account?",
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  color: Palette.dark_blue,
                                ),
                              ),
                              SizedBox(width: 3.w),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  "Sign In",
                                  style: TextStyle(
                                    color: Palette.blue,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.sp,
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<BaseModel<RegisterResponse>> callApiRegister() async {
    RegisterResponse response;
    newDateApiPass =
        DateUtilForPass().formattedDate(DateTime.parse('$_selectedDate'));
    Map<String, dynamic> body = {
      "name": _name.text,
      "email": _email.text,
      "phone": _phone.text,
      "dob": newDateApiPass,
      "gender": _selectGender,
      "password": _password.text,
      "phone_code": _phoneCode.text,
    };
    setState(() {
      Preferences.onLoading(context);
    });
    try {
      response = await RestClient(RetroApi2().dioData2()).registerRequest(body);
      if (response.success == true) {
        setState(() {
          Preferences.hideDialog(context);
          id = response.data!.id;
          // OneSignal.login("${response.data!.id.toString()}");
          /*response.data!.verify != 1
              ? Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OTPVerification(id: id),
                  ),
                )
              : */
          Navigator.pushReplacementNamed(context, "SignIn");
          Fluttertoast.showToast(
            msg:
                'Successfully registered ${response.data!.name}! Please login to continue!',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Palette.blue,
            textColor: Palette.white,
          );
        });
      }
      setState(() {
        Preferences.hideDialog(context);
      });
    } catch (error, stacktrace) {
      setState(() {
        Preferences.hideDialog(context);
      });
      // print("Exception occur: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  _selectDate(BuildContext context) async {
    DateTime? newSelectedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate != null
          ? _selectedDate!
          : DateTime.now().subtract(Duration(days: 365 * 18)),
      firstDate: DateTime(1950, 1),
      lastDate: DateTime.now().subtract(Duration(days: 365 * 18)),
    );
    if (newSelectedDate != null) {
      _selectedDate = newSelectedDate;
      _dob
        ..text = DateFormat('dd-MM-yyyy').format(_selectedDate!)
        ..selection = TextSelection.fromPosition(
          TextPosition(
              offset: _dob.text.length, affinity: TextAffinity.upstream),
        );
    }
  }
}
