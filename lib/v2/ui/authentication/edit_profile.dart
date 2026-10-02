import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:country_picker/country_picker.dart';
import 'package:doctro_patient/api/network_api.dart';
import 'package:doctro_patient/api/retrofit_Api.dart';
import 'package:doctro_patient/const/prefConstatnt.dart';
import 'package:doctro_patient/v2/ui/widgets/button_v2.dart';
import 'package:doctro_patient/v2/ui/widgets/custom_text_field.dart';
import 'package:doctro_patient/v2/ui/widgets/header.dart';
import 'package:doctro_patient/v2/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:sizer/sizer.dart';

import '../../../../const/preference.dart';
import '../../../api/base_model.dart';
import '../../../api/server_error.dart';
import '../../../const/Palette.dart';
import '../../../model/v2/update_profile_model.dart';
import '../../../model/v2/update_user_image_model.dart';
import '../../../model/v2/user_detail_model.dart';
import '../../utils/helper.dart';

class EditProfile extends StatefulWidget {
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  bool loading = false;

  List<String> gender = ['MALE', 'FEMALE'];
  String? _selectGender;
  String? selectDate;
  String name = "";
  String? image = "";
  String? email = "";
  String? msg = "";

  String newDateApiPass = "";
  String newDateUser = "";

  DateTime? _selectedDate;

  File? _proImage;
  final picker = ImagePicker();

  late var temp;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController _name = TextEditingController();
  TextEditingController _phoneCode = TextEditingController(
      text: SharedPreferenceHelper.getString(Preferences.phoneCode) ?? '+91');
  TextEditingController _phoneNo = TextEditingController();
  TextEditingController _dateOfBirth = TextEditingController();

  @override
  void initState() {
    super.initState();
    callApiUserProfile();
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: loading,
      opacity: 0.5,
      progressIndicator: SpinKitFadingCircle(
        color: Palette.primary,
        size: 50.0,
      ),
      child: Scaffold(
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: SingleChildScrollView(
            child: Column(
              children: [
                Header_v2(title: 'Edit Profile'),
                SizedBox(height: 3.h),
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Palette.primary,
                        blurRadius: 1.sp,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 8.h,
                        width: 8.h,
                        child: Stack(
                          clipBehavior: Clip.none,
                          fit: StackFit.expand,
                          children: [
                            _proImage != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(4.h),
                                    child: Image.file(
                                      _proImage!,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : CachedNetworkImage(
                                    alignment: Alignment.center,
                                    imageUrl: image!,
                                    imageBuilder: (context, imageProvider) =>
                                        CircleAvatar(
                                      radius: 4.h,
                                      backgroundColor: Palette.white,
                                      child: CircleAvatar(
                                        radius: 4.h,
                                        backgroundImage: imageProvider,
                                      ),
                                    ),
                                    placeholder: (context, url) =>
                                        SpinKitFadingCircle(
                                            color: Palette.primary),
                                    errorWidget: (context, url, error) =>
                                        ClipRRect(
                                      borderRadius: BorderRadius.circular(4.h),
                                      child: Image.asset(
                                          "assets/images/no_image.jpg"),
                                    ),
                                    height: 4.h,
                                    width: 4.h,
                                    fit: BoxFit.fitHeight,
                                  ),
                            Positioned(
                              top: 6.2.h,
                              left: 5.5.h,
                              child: GestureDetector(
                                onTap: () {
                                  _chooseProfileImage();
                                },
                                child: CircleAvatar(
                                  backgroundColor: Palette.dark_grey,
                                  radius: 2.3.w,
                                  child: Icon(
                                    Icons.add,
                                    color: Palette.white,
                                    size: 4.w,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Form(
                  key: _formKey,
                  child: Container(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 17, vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// Name ///
                          Text(
                            "First Name",
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: Palette.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 1.h),
                          CustomTextField(
                            textCapitalization: TextCapitalization.sentences,
                            controller: _name,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp('[a-zA-Z0-9]'),
                              )
                            ],
                            hint: "Name",
                          ),
                          SizedBox(height: 2.h),

                          /// Phone No. ///
                          Text(
                            "Phone No",
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: Palette.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 1.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                      countryListTheme: CountryListThemeData(
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(3.h),
                                          topRight: Radius.circular(3.h),
                                        ),
                                        inputDecoration: InputDecoration(
                                          labelText: "Search",
                                          hintText: "Start typing to search",
                                          prefixIcon: const Icon(Icons.search),
                                          border: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Palette.grey
                                                  .withValues(alpha: 0.2),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              SizedBox(
                                width: 70.w,
                                child: CustomTextField(
                                  textInputType: TextInputType.phone,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                        RegExp('[a-zA-Z0-9]'))
                                  ],
                                  controller: _phoneNo,
                                  hint: 'Phone No',
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 2.h),

                          /// Date Of Birth ///
                          Text(
                            "Date of Birth",
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: Palette.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 1.h),
                          Container(
                            height: 5.h,
                            child: CustomTextField(
                              textCapitalization: TextCapitalization.words,
                              focusNode: AlwaysDisabledFocusNode(),
                              controller: _dateOfBirth,
                              hint: "Date of Birth",
                              onTap: () {
                                _selectDate(context);
                              },
                            ),
                          ),
                          SizedBox(height: 2.h),

                          /// Gender ///
                          Text(
                            "Gender",
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: Palette.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 1.h),
                          CustomDropdown(
                            hint: "Select Gender",
                            value: _selectGender,
                            onChanged: (dynamic newValue) {
                              setState(
                                () {
                                  _selectGender = newValue;
                                },
                              );
                            },
                            validator: (dynamic value) =>
                                value == null ? "Please Select Gender" : null,
                            items: gender,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: Container(
          height: 10.h,
          child: ButtonV2(
            label: "Save",
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                if (_name.text.isEmpty) {
                  Fluttertoast.showToast(
                    msg: "Please Enter Name",
                  );
                } else if (_phoneNo.text.isEmpty) {
                  Fluttertoast.showToast(
                    msg: "Please Enter phone",
                  );
                } else {
                  callApiUpdateProfile();
                }
              }
            },
          ),
        ),
      ),
    );
  }

  Future<BaseModel<UserDetail>> callApiUserProfile() async {
    UserDetail response;
    setState(() {
      loading = true;
    });
    try {
      response = await RestClient(await RetroApi().dioData(context))
          .userDetailRequest();
      setState(() {
        loading = false;
        _name.text = response.name!;
        _phoneCode.text = response.phoneCode!;
        _phoneNo.text = response.phone!;
        selectDate = response.dob;
        _selectGender = response.gender!.toUpperCase();
        image = response.fullImage;
        email = response.email;
        newDateUser = DateUtil().formattedDate(DateTime.parse(selectDate!));
        _dateOfBirth.text = newDateUser;
      });
    } catch (error, stacktrace) {
      setState(() {
        loading = false;
      });
      // print("Exception occur: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  _selectDate(BuildContext context) async {
    DateTime? newSelectedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate != null ? _selectedDate! : DateTime.now(),
      firstDate: DateTime(1950, 1),
      lastDate: DateTime.now(),
    );
    if (newSelectedDate != null) {
      _selectedDate = newSelectedDate;
      _dateOfBirth
        ..text = DateFormat('dd-MM-yyyy').format(_selectedDate!)
        ..selection = TextSelection.fromPosition(
          TextPosition(
              offset: _dateOfBirth.text.length,
              affinity: TextAffinity.upstream),
        );
    }
  }

  Future<BaseModel<UpdateProfile>> callApiUpdateProfile() async {
    try {
      UpdateProfile response;
      if (_selectedDate != null) {
        temp = '$_selectedDate';
      } else {
        temp = '$selectDate';
      }
      newDateApiPass = DateUtilForPass().formattedDate(DateTime.parse(temp));
      Map<String, dynamic> body = {
        "name": _name.text,
        "phone_code": _phoneCode.text,
        "phone": _phoneNo.text,
        "dob": newDateApiPass,
        "gender": _selectGender,
        "language": Preferences.current_language_code,
      };
      setState(() {
        loading = true;
      });

      response = await RestClient(await RetroApi().dioData(context))
          .updateProfileRequest(body);
      setState(() {
        if (response.success == true) {
          setState(() {
            loading = false;
            SharedPreferenceHelper.setString(
                FirestoreConstants.nickname, _name.text);
            Fluttertoast.showToast(
              msg: '${response.msg}',
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Palette.primary,
              textColor: Palette.white,
            );
            Navigator.pushNamed(context, 'Home');
          });
        }
      });

      return BaseModel()..data = response;
    } catch (e) {
      setState(() {
        loading = false;
      });
      logger.e(e);
      return BaseModel()..setException(ServerError.withError(error: e));
    }
  }

  Future<BaseModel<UpdateUserImage>> callApiUpdateImage() async {
    UpdateUserImage response;
    Map<String, dynamic> body = {
      "image": image,
    };
    setState(() {
      loading = true;
    });
    try {
      // log("image = $image");
      response = await RestClient(await RetroApi().dioData(context))
          .updateUserImageRequest(body);
      setState(() {
        loading = false;
        if (response.success == true) {
          setState(() {
            loading = false;
            SharedPreferenceHelper.setString(
                FirestoreConstants.photoUrl, image.toString());
            msg = response.data;
            Fluttertoast.showToast(
              msg: 'test $msg',
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Palette.primary,
              textColor: Palette.white,
            );
          });
        }
      });
    } catch (error, stacktrace) {
      setState(() {
        loading = false;
      });
      // print("Exception occur: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  void _proImgFromGallery() async {
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );
    setState(
      () {
        if (pickedFile != null) {
          SharedPreferenceHelper.setString(Preferences.image, pickedFile.path);
          _proImage =
              File(SharedPreferenceHelper.getString(Preferences.image)!);
          List<int> imageBytes = _proImage!.readAsBytesSync();
          image = base64Encode(imageBytes);
          callApiUpdateImage();
        } else {
          // print('No image selected.');
        }
      },
    );
  }

  void _proImgFromCamera() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    setState(() {
      if (pickedFile != null) {
        SharedPreferenceHelper.setString(Preferences.image, pickedFile.path);
        _proImage = File(SharedPreferenceHelper.getString(Preferences.image)!);
        List<int> imageBytes = _proImage!.readAsBytesSync();
        image = base64Encode(imageBytes);
        callApiUpdateImage();
      } else {
        // print('No image selected.');
      }
    });
  }

  void _chooseProfileImage() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Container(
            child: new Wrap(
              children: <Widget>[
                new ListTile(
                    leading: new Icon(Icons.photo_library),
                    title: new Text(
                      "From Gallery",
                    ),
                    onTap: () {
                      _proImgFromGallery();
                      Navigator.of(context).pop();
                    }),
                new ListTile(
                  leading: new Icon(Icons.photo_camera),
                  title: new Text(
                    "From Camera",
                  ),
                  onTap: () {
                    _proImgFromCamera();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
